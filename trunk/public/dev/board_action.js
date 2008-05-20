
function handle_release_of_piece(draggable, droparea){
   //for now release it in the DOM, moving it
   $('move_from_coord').value = draggable.parentNode.id;
   $('move_to_coord').value = droparea.id;

   var origSquare = draggable.parentNode;

   origSquare.removeChild(draggable);
   origSquare.innerHTML = '&nbsp;';
   
   droparea.innerHTML = '';
   droparea.appendChild(draggable);

   
   //todo: request the server notate this move

}
