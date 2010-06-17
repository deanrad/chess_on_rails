# File:    breakpoints.rb
# Purpose: can be required (in environment.rb, after require 'ruby-debug', for example) 
# Note:    If there are no breakpoints added in this file, only 'debugger' 
#   statements in your code will allow an attached debugger to be able
#   to control program flow, set additional breakpoints, etc...
#  
#  Debugger.add_breakpoint(source, pos, condition = nil) -> breakpoint
# ------------------------------------------------------------------------
#    Adds a new breakpoint. 
#      source    : the name of a file or a class name.
#      pos       : a line number or a method name if _source_ is a class name.
#      condition : a string which will activate the breakpoint if it evals to true

Debugger.add_breakpoint 'ActionController::Dispatcher', 'dispatch'
