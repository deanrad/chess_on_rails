
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

    // [w, f, pawn] for example

    img_base = piece[2] + "_" + piece[0]
    board_id = (piece[1] ? piece[1].substr(0,1)+'_' : '') + img_base;

    var img = '<img id="' + board_id + '" class="piece ' + allowed_moves + 
	    '" src="/images/sets/default/' + img_base + '.png" />';

    var scr = '<scr' + 'ipt>new Draggable("' + board_id + '", {revert:true, snap:[42,42]})</scr' + 'ipt>';
    return img + scr;
}

// clears out the contents of each square on the board, and inserts anew from JSON
function set_board(move_num){
  $$('td.piece_container').each( 
     function( elem ){ 
       try{
	   //console.log( new Template("Alert: all_boards.length=#{msg}").evaluate({msg: all_boards.length}) );
	 allowed_moves = (current_allowed_moves.length > 0) ? current_allowed_moves[elem.id] : ""
	 elem.update( markup_piece( elem.id, all_boards[move_num][elem.id], allowed_moves ) );
       }
       catch(ex){
	   alert(ex); return;
       }
     }
  );
}
