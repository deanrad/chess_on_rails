require 'rubygems'
require 'RMagick'
include Magick

dims = [1400,1900]
mult = 1.0
piece_dim = 150
piece_border= 12

#the mapping to rows and columns, respectively of the pieces, based on their type and color
piece_index_map = { 
  'rook_b' => [0, 0], 'knight_b' => [0, 1], 'bishop_b' => [0, 2], 
  'king_b' => [0, 3], 'queen_b' => [0, 4], 'pawn_b' => [1, 0],
  'rook_w' => [3, 0], 'knight_w' => [3, 1], 'bishop_w' => [3, 2], 
  'king_w' => [3, 3], 'queen_w' => [3, 4], 'pawn_w' => [2, 0]
}

svg_src = Image.read( './public/images/chess_board_and_pieces_source.svg' ).first
pix_src = svg_src.scale(dims[0], dims[1])

row_offset = [-10, 114, 1630, 1752]
row_num = ARGV[0].to_i || 1

(0..7).each do |col_num|
  crop_dims = [95 + piece_dim*col_num + piece_border, row_offset[row_num] + piece_border] + 
    [piece_dim-2*piece_border, piece_dim-2*piece_border]
  #pix_src.crop( *crop_dims ).display
end
exit
