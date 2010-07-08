module DbFreeIncludes

  IRB_REQUIRES = %w{
   rubygems 
   irb/completion
   logger
   active_record_mock
   chess_fixtures
   chess_active_record_mock
  }

  # util - No util.rb found in project; deleted.
  # spec/db_free_spec_helper - not needed for script/db_free_run and erring; deleted.

  IRB_LOAD_PATHS = %w{
    lib
    spec/mocks
    app/models
    app/models/pieces
  }

end
