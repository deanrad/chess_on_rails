//each piece is given sentience as a javascript object
//preprocess_pieces();


pieces.each( function (p) {
	var img_name = ( (p.type.split("_").length==2) ? p.type.split("_")[1] : p.type) + '_' + p.side.substring(0,1);
    $(p.position).update( "<img class='piece' src='/images/chess_pieces/" + img_name + ".gif' id='" + p.side + '_' + p.type + "' />" );

    var d = new Draggable( p.side + '_' + p.type , {snap:[48,48],revert:true});
  }
)

//add droppability to rows here because I can't think of the best place to do this..
$('board_table').getElementsBySelector('td').each(
  function( cell ){
    Droppables.add(cell, {hoverclass:'hoverActive', onDrop:handle_release_of_piece} ); 
  }
);

function handle_release_of_piece(draggable, droparea){
   //for now release it in the DOM, moving it
   $('move_from_coord').value = draggable.parentNode.id;
   $('move_to_coord').value = droparea.id;

   draggable.parentNode.removeChild(draggable);
   droparea.appendChild(draggable);
}
