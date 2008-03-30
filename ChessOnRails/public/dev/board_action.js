//each piece is given sentience as a javascript object
preprocess_pieces();


pieces.each( function (p) {
    $(p.position).update( p.image() );
    new Draggable(p.id, {snap:[48,48],revert:true});
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
   $('new_move_from_coord').value = draggable.parentNode.id;
   $('new_move_to_coord').value = droparea.id;

   draggable.parentNode.removeChild(draggable);
   droparea.appendChild(draggable);
}

function preprocess_pieces(){
  piece_template = new Template("&nbsp;<img class='piece' src='/images/chess_pieces/#{image_name}.gif' id='#{id}'/>");

  pieces.each( function (p){ 
     p.image_name = ( (p.type.split("_").length==2) ? p.type.split("_")[1] : p.type) + '_' + p.side.substring(0,1);
     p.id = p.side + '_' + p.type;
     
     p.image = function(){
        if (this.active)
          return piece_template.evaluate(this);
        else
          return "&nbsp;";
     }
  });
}