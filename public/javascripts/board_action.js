
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

    var img = '<img id="' + board_id + '" class="piece ' + (allowed_moves ? allowed_moves : '') + 
	    '" src="/images/sets/default/' + img_base + '.png" />';

    var scr = '<scr' + 'ipt type="text/javascript">new Draggable("' + board_id + '", {revert:true, snap:[42,42]})</scr' + 'ipt>';
    return img + scr;
}

// clears out the contents of each square on the board, and inserts anew from JSON, restoring the set of allowed_moves
function set_board(move_num, allowed_moves){
  log('setting board to move ' + move_num);
  //try updating the move indicator to show what you're displaying
  try{
    $$('.move_list_currently_displayed').each( function( elem ){ elem.removeClassName('move_list_currently_displayed'); } );
    $('move_' + move_num).addClassName('move_list_currently_displayed');
  }
  catch(ex){
    log(ex);
  }
  $$('td.piece_container').each( 
     function( elem ){ 
       try{
	 elem.update( markup_piece( elem.id, all_boards[move_num][elem.id], allowed_moves[elem.id] ) );
       }
       catch(ex){
	   log(ex.description); return;
       }
     }
  );
}
/* board flipping logic */
      //opponent_view will in future be set by server (if we store this setting, which we dont currently)
      var opponent_view = false;

      var rows_stack    = []; //FILO for reversing
      var squares_stack = []; //FILO for reversing
      
      function toggleBoardView(){
        da_board = $('board_table');
        for(i=0; i<8; i++){
          rows_stack.push( $$('.row_container')[0].remove() );
        }

        bottom_labels = $$('.bottom_labels')[0].remove();

        for(r=0; r<8; r++){    //row
          for(c=1; c<9; c++){  //column
            squares_stack.push( rows_stack[r].select('.piece_container')[0].remove() );
          }
          for(c=1; c<9; c++){  //column
            rows_stack[r].insert( squares_stack.pop() );
          }
        }

        //we want bottom labels processed by the reversal as well
        for(c=1; c<9; c++){  //column
          squares_stack.push( bottom_labels.select('.label')[0].remove() );
        }
        for(c=1; c<9; c++){  //column
          bottom_labels.insert( squares_stack.pop() );
        }

        for(i=0; i<8; i++){
          da_board.insert( rows_stack.pop() );
        }
        da_board.insert( bottom_labels );
      }
