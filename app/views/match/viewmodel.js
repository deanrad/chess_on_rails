// Because client state will change while the page is loaded, we set up an object
// with fields to track it, and methods to manipulate it. This is called a viewmodel.
// Then we bind (using HTML5 data-bind attributes and knockout syntax) DOM elements
// to the viewmodel, and updating happens automatically as the viewmodel is changed
// whether by user-interaction, or AJAX polls.
var game_view_model = {
  your_turn:                new ko.observable(<%= your_turn %>)
};
ko.applyBindings(document.body, game_view_model);
