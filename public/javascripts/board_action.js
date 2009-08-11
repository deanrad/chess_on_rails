
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

Droppables.add('a1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a1' } );
Droppables.add('a2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a2' } );
Droppables.add('a3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a3' } );
Droppables.add('a4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a4' } );
Droppables.add('a5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a5' } );
Droppables.add('a6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a6' } );
Droppables.add('a7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a7' } );
Droppables.add('a8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'a8' } );

Droppables.add('b1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b1' } );
Droppables.add('b2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b2' } );
Droppables.add('b3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b3' } );
Droppables.add('b4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b4' } );
Droppables.add('b5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b5' } );
Droppables.add('b6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b6' } );
Droppables.add('b7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b7' } );
Droppables.add('b8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'b8' } );

Droppables.add('c1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c1' } );
Droppables.add('c2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c2' } );
Droppables.add('c3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c3' } );
Droppables.add('c4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c4' } );
Droppables.add('c5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c5' } );
Droppables.add('c6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c6' } );
Droppables.add('c7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c7' } );
Droppables.add('c8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'c8' } );

Droppables.add('d1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd1' } );
Droppables.add('d2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd2' } );
Droppables.add('d3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd3' } );
Droppables.add('d4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd4' } );
Droppables.add('d5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd5' } );
Droppables.add('d6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd6' } );
Droppables.add('d7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd7' } );
Droppables.add('d8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'd8' } );

Droppables.add('e1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e1' } );
Droppables.add('e2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e2' } );
Droppables.add('e3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e3' } );
Droppables.add('e4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e4' } );
Droppables.add('e5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e5' } );
Droppables.add('e6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e6' } );
Droppables.add('e7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e7' } );
Droppables.add('e8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'e8' } );

Droppables.add('f1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f1' } );
Droppables.add('f2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f2' } );
Droppables.add('f3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f3' } );
Droppables.add('f4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f4' } );
Droppables.add('f5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f5' } );
Droppables.add('f6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f6' } );
Droppables.add('f7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f7' } );
Droppables.add('f8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'f8' } );

Droppables.add('g1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g1' } );
Droppables.add('g2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g2' } );
Droppables.add('g3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g3' } );
Droppables.add('g4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g4' } );
Droppables.add('g5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g5' } );
Droppables.add('g6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g6' } );
Droppables.add('g7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g7' } );
Droppables.add('g8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'g8' } );

Droppables.add('h1', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h1' } );
Droppables.add('h2', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h2' } );
Droppables.add('h3', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h3' } );
Droppables.add('h4', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h4' } );
Droppables.add('h5', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h5' } );
Droppables.add('h6', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h6' } );
Droppables.add('h7', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h7' } );
Droppables.add('h8', {hoverclass:'hoverActive', onDrop:handle_release_of_piece, accept: 'h8' } );
