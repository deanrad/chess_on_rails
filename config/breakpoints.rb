# File:    breakpoints.rb
# Purpose: can be required (in environment.rb, after require 'ruby-debug', for example) 
# to set breakpoints externally instead of via inline 'debugger' calls
# Refer:   Debugger::add_breakpoint, Debugger::add_catchpoint
# Examples:  
#   Debugger.add_breakpoint 'SomeController', 'action', 'cust_id == 100'  # must be true
#   Debugger.add_breakpoint 'SomeController', 'action'
#   Debugger.add_catchpoint 'CustomError'   # will break when thrown anywhere

Debugger.add_breakpoint 'MatchesController', 'show_move', 'params[:move_num] == "1"'
