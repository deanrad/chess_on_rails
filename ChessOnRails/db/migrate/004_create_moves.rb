class CreateMoves < ActiveRecord::Migration
	def self.up
		create_table :moves do |t|
			
			t.column :match_id, :int
			t.column :moved_by, :int  # 1 or 2 only
			
			#example a2, b8 - note for 8x8 board, a one byte uint could indicate
			# a to/from coordinate in far less space, but for now string rep is fine
			t.column :from_coord, :string, :limit=>2
			t.column :to_coord, :string, :limit=>2
			
			#a notation summary of the move
			t.column :notation, :string, :limit=>10
			
			private
			
			#calculated but stored for ease of computation
			t.column :castled, :int, :default=>0 #used as bool
			t.column :captured_piece_coord, :string, :limit=>2
			
			
			t.timestamps
		end
	end
	
	def self.down
		drop_table :moves
	end
end
