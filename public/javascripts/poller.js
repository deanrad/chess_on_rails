/**
 * smart_polling - A utility to poll the server for data changes while being smart the XHR requests.
 * http://925html.com/code/smart-polling/
 * 
 * Copyright (c) 2009 Eric Ferraiuolo - http://eric.ferraiuolo.name
 * MIT License - http://www.opensource.org/licenses/mit-license.php
 */

/**
 * Create a poller to continually ask a server if a resource has been modified.
 * 
 * @module poller
 * @requires io-base, base
 */

var Poller,
	POLLER = 'poller',
	
	isObject = Y.Lang.isObject,
	isString = Y.Lang.isString,
	isNumber = Y.Lang.isNumber,
	isBoolean = Y.Lang.isBoolean,
	
	INTERVAL = 'interval',
	URL = 'url',
	QUERY_PARAMS = 'queryParams',
	HEADERS = 'headers',
	TIMEOUT = 'timeout',
	PAUSE_INACTIVE = 'pauseInactive',
	POLLING = 'polling',
	
	START = 'start',
	STOP = 'stop',
	REQUEST = 'request',
	RESPONSE = 'response',
	MODIFIED = 'modified';

/**
 * Create a polling task to continually check the server at the specified interval for updates of a resource at a URI.
 * The poller will use conditional GET requests and notifiy the client via Events when the resource has changed.
 * 
 * @class Poller
 * @extends Base
 * @param {Object} config Configuration Object
 * @constructor
 */
Poller = function (config) {
	
	Poller.superclass.constructor.apply( this, arguments );
	
};

Y.mix( Poller, {
	
	/**
	 * The identity of the component.
	 * 
	 * @property Poller.NAME
	 * @type String
	 * @static
	 */
	NAME : POLLER,
	
	/**
	 * Static property used to define the default attribute configuration of
	 * the component.
	 *
	 * @property Poller.ATTRS
	 * @type Object
	 * @static
	 */
	ATTRS : {
		
		/**
		 * The time in milliseconds for which the component should send a request to the server.
		 * 
		 * @attribute interval
		 * @type Number
		 * @default 10000
		 */
		interval : {
			value : 10000,
			validator : isNumber
		},
		
		/**
		 * The URL of the resource which the component will check for modifications.
		 * 
		 * @attribute url
		 * @type String
		 * @default null
		 */
		url : {
			value : null,
			validator : isString
		},
		
		/**
		 * A set of name=value pairs to be appened to the URL requests will be sent to.
		 * 
		 * @attribute queryParams
		 * @type String
		 * @default null
		 */
		queryParams : {
			value : null,
			validator : isString
		},
		
		/**
		 * An Object containing the key : value pairs for any HTTP headers to be send with requests.
		 * 
		 * @attribute headers
		 * @type Object
		 * @default null
		 */
		headers : {
			value : null,
			validator : isObject
		},
		
		/**
		 * The time in milliseconds which the XHR request should abort if no response is received.
		 * 
		 * @attribute timeout
		 * @type Number
		 * @default 5000
		 */
		timeout : {
			value : 5000,
			set : function (v) {
				var interval = this.get(INTERVAL);
				return (v <= interval) ? v : interval;
			},
			validator : isNumber
		},
		
		/**
		 * Choice for the polling to be paused if the browser window loses focus, becoming an inactive window.
		 * 
		 * @attribute pauseInactive
		 * @type Boolean
		 * @default false
		 */
		pauseInactive : {
			value : false,
			validator : isBoolean
		},
		
		/**
		 * A read-only attribute the client can check to see if the component is activly polling the server.
		 * 
		 * @attribute polling
		 * @type Boolean
		 * @default false
		 * @final
		 */
		polling : {
			value : false,
			readOnly : true
		}
		
	}
	
});

Y.extend( Poller, Y.Base, {
	
	/**
	 * Reference to the timer object that's polling the server.
	 * 
	 * @property _poller
	 * @type Y.later
	 * @protected
	 */
	_poller : null,
	
	/**
	 * Last-Modified date of the resource that the server returned, used to determine if the resource has changed.
	 * 
	 * @property _modifiedDate
	 * @type String
	 * @protected
	 */
	_modifiedDate : null,
	
	/**
	 * Etag of the resource returned by the server, used to determine if the resource has changed.
	 * 
	 * @property _etag
	 * @type String
	 * @protected
	 */
	_etag : null,
	
	/**
	 * Reference to the timer object which is waiting to resume from a pause request.
	 * 
	 * @property _paused
	 * @type Y.later
	 * @protected
	 */
	_paused : false,
	
	/**
	 * Event handle referencing the binding to the window's focus event.
	 * 
	 * @property _focusHandle
	 * @type Event.Handle
	 * @protected
	 */
	_focusHandle : null,
	
	/**
	 * Event handle referencing the binding to the window's blur event.
	 * 
	 * @property _blurHandle
	 * @type Event.Handle
	 * @protected
	 */
	_blurHandle : null,
	
	/**
	 * Construction of the component linking up and publishing event during initialization.
	 * 
	 * @method initializer
	 * @param {Object} config Configuration Ojbect
	 * @protected
	 */
	initializer : function (config) {
		this.after( 'intervalChange', this._afterIntervalChange );
		this.after( 'urlChange', this._afterUrlChange );
		this.after( 'headersChange', this._afterHeadersChange );
		this.after( 'pauseInactiveChange', this._afterPauseInactiveChange );
		
		/**
		 * Signals that polling has started, poller:start.
		 * 
		 * @event start
		 * @param {Event.Facade} e Event Facade
		 */
		this.publish(START);
		
		/**
		 * Signals that polling has stopped, poller:stop.
		 * 
		 * @event stop
		 * @param {Event.Facade} e Event Facade
		 */
		this.publish(STOP);
		
		/**
		 * Signals that the component has sent a XHR request to the Server.
		 * The request object is passed to subscribers of the event, poller:request.
		 * 
		 * @event request
		 * @param {Event.Facade} e Event Facade
		 * @param {Object} tx Y.io Request Object
		 */
		this.publish(REQUEST);
		
		/**
		 * Signals that the component has received a response (io:complete) for the server, poller:response.
		 * 
		 * @event response
		 * @param {Event.Facade} e Event Facade
		 * @param {Number} txId Y.io Transaction ID
		 * @param {Object} r Y.io Response Object
		 * @param {MIXED} args Arguments passed to response handler
		 */
		this.publish(RESPONSE);
		
		/**
		 * Signals that the resource the component is pulling the server for has been modified.
		 * This is the interesting event for the client ot subscribe to.
		 * The subscriber could, for example, update the UI in response to this event, poller:modified.
		 * 
		 * @event modified
		 * @param {Event.Facade} e Event Facade
		 * @param {Number} txId Y.io Transaction ID
		 * @param {Object} r Y.io Response Object
		 * @param {MIXED} args Arguments passed to response handler
		 */
		this.publish(MODIFIED);
		
		if ( this.get(PAUSE_INACTIVE) ) {
			this._enablePauseInactive();
		}
	},
	
	/**
	 * Deconstruction of the component. Stops polling and removes event internal listeners.
	 * 
	 * @method destructor
	 * @protected
	 */
	destructor : function () {
		this.stop();
		this._disablePauseInactive();
	},
	
	/**
	 * Starts the polling task, the poller:start event is fired as a result of calling this method.
	 * A request will be sent to the server right at the time of calling this method;
	 * continued by sending subsequent requests at the set interval.
	 * If the pause method has been called, calling start will clear the pause.
	 * 
	 * @method start
	 * @chainable
	 */
	start : function () {
		this._clearPause();
		this._startPolling();
		this._set( POLLING, true );
		return this;
	},
	
	/**
	 * Stops the polling task, the poller:stop event is fired.
	 * If the paused method has been called, calling start will clear the pause.
	 * 
	 * @method stop
	 * @chainable
	 */
	stop : function () {
		this._clearPause();
		this._stopPolling();
		this._set( POLLING, false );
		return this;
	},
	
	/**
	 * Pauses the polling task for a duration.
	 * This method first calls stop, which will fire the poller:stop event;
	 * which will also clear out a waiting pause to resume.
	 * 
	 * @method pause
	 * @param {Number} duration milliseconds until resuming
	 * @chainable
	 */
	pause : function (duration) {
		this.stop();
		
		if ( isNumber(duration) ) {
			this._paused = Y.later( duration, this, this.start );
		}
		
		return this;
	},
	
	/**
	 * Protected method that actually starts the polling task.
	 * Calling this method will send a request to the server, fire the poller:start event, and create the interval task.
	 * 
	 * @method _startPolling
	 * @protected
	 */
	_startPolling : function () {
		if ( ! this._poller ) {
			this.fire(START);
			this.sendRequest();
			this._poller = Y.later( this.get(INTERVAL), this, this.sendRequest, null, true );
		}
	},
	
	/**
	 * Protected method that actually stops the polling task.
	 * Calling this method will stop the poller and fire the poller:stop event.
	 * 
	 * @method _stopPolling
	 * @protected
	 */
	_stopPolling : function () {
		if ( this._poller ) {
			this._poller.cancel();
			this._poller = null;
			this.fire(STOP);
		}
	},
	
	/**
	 * Utility method used to clear a pause timer that has been set.
	 * 
	 * @method _clearPause
	 * @protected
	 */
	_clearPause : function () {
		if ( this._paused ) {
			this._paused.cancel();
			this._paused = false;
		}
	},
	
	/**
	 * Sends the XHR request to the server at the given URL (resource).
	 * This is method is call at the set interval while polling.
	 * Calling this method will fire the poller:request event.
	 * 
	 * @method sendRequest
	 * @chainable
	 */
	sendRequest : function () {
		var config, headers, tx;
		
		headers = this.get(HEADERS);
		if ( this._etag ) {
			headers = Y.merge( headers, { 'If-None-Match':this._etag });
		} else if ( this._modifiedDate ) {
			headers = Y.merge( headers, { 'If-Modified-Since':this._modifiedDate });
		}
		
		config = {
			
			method : 'GET',
			data : this.get(QUERY_PARAMS),
			headers : headers,
			on : {
				complete : this._handleResponse,
				success : this._handleModified
			},
			context : this,
			timeout : this.get(TIMEOUT)
			
		};
		
		tx = Y.io( this.get(URL), config );
		this.fire( REQUEST, tx );
		return this;
	},
	
	/**
	 * Handles the response from a completed XHR request.
	 * Fires the poller:response event.
	 * 
	 * @method _handleResponse
	 * @param {Number} txId Y.io Transaction ID
	 * @param {Object} r Y.io Response Object
	 * @param {MIXED} args Arguments passed to response handler
	 * @protected
	 */
	_handleResponse : function ( txId, r, args ) {
		this.fire( RESPONSE, txId, r, args );
	},
	
	/**
	 * Handles the response from a successful XHR request (2xx response status).
	 * The resource has changed on the server if this method has been called.
	 * Fires the poller:modified event.
	 * 
	 * @method _handleModified
	 * @param {Number} txId Y.io Transaction ID
	 * @param {Object} r Y.io Response Object
	 * @param {MIXED} args Arguments passed to response handler
	 * @protected
	 */
	_handleModified : function ( txId, r, args ) {
		this._etag = r.getResponseHeader('Etag');
		this._modifiedDate = r.getResponseHeader('Last-Modified');
		this.fire( MODIFIED, txId, r, args );
	},
	
	/**
	 * Attaches the event handles to the focus and blur events on the window.
	 * Provides a way to automatically pause polling when the browser window is inactive,
	 * and starts the polling process right when the windows becomes active again.
	 * 
	 * @method _enablePauseInactive
	 * @protected
	 */
	_enablePauseInactive : function () { // TODO: Make more robust across browsers
		this._focusHandle = Y.on( 'focus', this._handleFocus, window, this );
		this._blurHandle = Y.on( 'blur', this._handleBlur, window, this );
	},
	
	/**
	 * Detacheds the event handles from the window's focus and blur events.
	 * Preventing the polling to pause when the window is inactive, polling will continue until stop or pause is called.
	 * 
	 * @method _disablePauseInactive
	 * @protected
	 */
	_disablePauseInactive : function () {
		this._focusHandle.detach();
		this._blurHandle.detach();
	},
	
	/**
	 * Handles the window coming into focus.
	 * Checks that the component is activly polling (stop hasn't been called), and resumes the polling task.
	 * 
	 * @method _handleFocus
	 * @param {Event} e Window focus event
	 * @protected
	 */
	_handleFocus : function (e) {
		if ( this.get(POLLING) && Y.Node.getDOMNode(e.target) === document ) {
			this._startPolling();
		}
	},
	
	/**
	 * Handles the window losing focus, blur.
	 * Checks that the component is activly polling (stop hasn't been called), and pauses the polling task.
	 * 
	 * @method _handleBlur
	 * @param {Object} e
	 * @protected
	 */
	_handleBlur : function (e) {
		if ( this.get(POLLING) && Y.Node.getDOMNode(e.target) === document ) {
			this._stopPolling();
		}
	},
	
	/**
	 * If the polling task is active, it will be stopped then started to use the new interval.
	 * 
	 * @method _afterIntervalChange
	 * @param {Event} e intervalChange custom event
	 * @protected
	 */
	_afterIntervalChange : function (e) {
		if ( this.get(POLLING) ) {
			this._stopPolling();
			this._startPolling();
		}
	},
	
	/**
	 * Invalidate the cached etag and modifiedDate used to determine if the resource has been changed.
	 * If the polling task is active then send a request to the server right away.
	 * 
	 * @method _afterUrlChange
	 * @param {Event} e urlChange custom event
	 * @protected
	 */
	_afterUrlChange : function (e) {
		this._etag = null;
		this._modifiedDate = null;
		if ( this.get(POLLING) ) {
			this.sendRequest();
		}
	},
	
	/**
	 * Invalidate the cached etag and modifiedDate used to determine if the resource has been changed.
	 * Changing the HTTP headers can effect the response returned by the server.
	 * Changing this attributed is treated like the changing the url attribute.
	 * 
	 * @method _afterHeadersChange
	 * @param {Event} e headersChange custom event
	 * @protected
	 */
	_afterHeadersChange : function (e) {
		this._etag = null;
		this._modifiedDate = null;
		if ( this.get(POLLING) ) {
			this.sendRequest();
		}
	},
	
	/**
	 * Enable/disable the pausing/resuming of the polling task when the window has become inactive/active.
	 * 
	 * @method _afterPauseInactiveChange
	 * @param {Event} e pauseInactiveChange custom event
	 * @protected
	 */
	_afterPauseInactiveChange : function (e) {
		if ( e.newVal === true ) {
			this._enablePauseInactive();
		} else {
			this._disablePauseInactive();
		}
	}
	
});

Y.Poller = Poller;
