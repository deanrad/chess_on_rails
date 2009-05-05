
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

    img_base = piece['function'] + '_' + piece['side'].substr(0,1);
    board_id = (piece['discriminator'] ? piece['discriminator'].substr(0,1)+'_' : '') + img_base;

    var img = '<img id="' + board_id + '" class="piece ' + allowed_moves + 
	    '" src="/images/sets/default/' + img_base + '.png" />';

    var scr = '<scr' + 'ipt>new Draggable("' + board_id + '", {revert:true, snap:[42,42]})</scr' + 'ipt>';
    return img + scr;
}