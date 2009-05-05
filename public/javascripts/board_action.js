
function handle_release_of_piece(draggable, droparea){

   var origSquare = draggable.parentNode;

   //for now release it in the DOM, moving it
   $('move_from_coord').value = draggable.parentNode.id;
   $('move_to_coord').value = droparea.id;

   origSquare.removeChild(draggable);
   origSquare.innerHTML = '&nbsp;';
   
   droparea.innerHTML = '';
   droparea.appendChild(draggable);

   //this should perhaps be an option but for ease of playability...
   $('new_move_form').submit();
   
}

function markup_piece( position, piece, allowed_moves ){
    //TODO render template from piece['side'], piece['function'] 
    if (piece == null) return '&nbsp;';

    //TODO string template ? 
    var s = '<img src="/images/sets/default/' + piece['function'] + '_' + piece['side'].substr(0,1)+ '.png" />';

    //TODO 
    return s;
}