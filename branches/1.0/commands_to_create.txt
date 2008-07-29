'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This file represents as list of commands which can be 'replayed' to partially create the project
' exectuted from inside root folder named EnPassant
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
rails en_passant -d mysql
cd en_passant
rake db:create:all
ruby script/plugin source http://svn.techno-weenie.net/projects/plugins
ruby script/plugin install restful_authentication
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Edit environments/production and development.rb to use active_record_store for sessions
' Facebook will require this
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
ruby script/generate authenticated player sessions
rake db:sessions:create
rake db:migrate
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' At this point a rake test should succeed - go ahead and run one if you like
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
ruby script/generate resource match player1_id:integer player2_id:integer active:boolean winner:integer outcome:string
ruby script/generate resource move  match_id:integer move_number:integer from_coord:string to_coord:string notation:string castled:boolean promotion_piece:string en_passant_capture_coord:string




