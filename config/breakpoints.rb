# File:    breakpoints.rb
# Purpose: can be required (in environment.rb, after require 'ruby-debug', for example) 
# Note:    If there are no breakpoints added in this file, only 'debugger' 
#   statements in your code will allow an attached debugger to be able
#   to control program flow, set additional breakpoints, etc...
#  
#  Debugger.add_breakpoint(source, pos, condition = nil) -> breakpoint
# ------------------------------------------------------------------------
#    Adds a new breakpoint. _source_ is a name of a file or a class.
#     _pos_ is a line number or a method name if _source_ is a class
#     name. _condition_ is a string which is evaluated to +true+ when
#     this breakpoint is activated.

Debugger.add_breakpoint 'ActionController::Dispatcher', 'dispatch'
