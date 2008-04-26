//file which breathes interactivity into the chess game - 
// ultimately this should be rails-emitted into views - for now this static inclusion does alright..

pieces.each( function (p) {

    $(p.position).update( "<img " + "class='piece " + p.allowed_moves + "' src='/images/chess_pieces/" + p.img_name + ".gif' id='" + p.client_id + "' />" );

    var d = new Draggable( p.client_id , {snap:[48,48],revert:true});
  }
)

//add droppability to rows here because I can't think of the best place to do this..
$('board_table').getElementsBySelector('td').each(
  function( cell ){
    Droppables.add(cell, {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: cell.id } ); 
  }
);

function handle_release_of_piece(draggable, droparea){
   //for now release it in the DOM, moving it
   $('move_from_coord').value = draggable.parentNode.id;
   $('move_to_coord').value = droparea.id;

   var origSquare = draggable.parentNode;

   origSquare.removeChild(draggable);
   origSquare.innerHTML = '&nbsp;';
   
   droparea.innerHTML = '';
   droparea.appendChild(draggable);

   
   //request the server notate this move
   //todo: this authenticity token is unlikely to be correct in all sessions
   var value = $('new_move_form').serialize();
   try{
	   new Ajax.Updater('new_move_notation', '/move/notate', {asynchronous:true, evalScripts:true, parameters:value + '&authenticity_token=' + encodeURIComponent('a9b1ff952fa075340e0dd3a96ff8b51e428583a1')});
	}
	catch(ex){
		$('new_move_notation').innerHTML = "??";
	}
}
