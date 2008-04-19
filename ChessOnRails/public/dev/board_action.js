//each piece is given sentience as a javascript object
//preprocess_pieces();


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

   draggable.parentNode.removeChild(draggable);
   
   droparea.innerHTML = '';
   droparea.appendChild(draggable);
}
