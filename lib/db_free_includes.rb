module DbFreeIncludes

  IRB_REQUIRES = %w{
   rubygems 
   irb/completion
   logger
   util
   active_record_mock
   spec/db_free_spec_helper
   chess_fixtures
   chess_active_record_mock
  }

  IRB_LOAD_PATHS = %w{
    lib
    spec/mocks
    app/models
    app/models/pieces
  }

end
