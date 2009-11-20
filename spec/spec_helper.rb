# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'ruby-debug'
require 'spec'
require 'spec/rails'
require 'mocha'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false

  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.global_fixtures = :all # :matches, :players, :moves, :users

  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
end

# Translates the key provided, and uses the model given to provide its attributes
# and any custom methods named in its ERROR_FIELDS constant to I18n interpolation
def t key, model = nil
  return I18n.t(key) unless model

  h = model.attributes.symbolize_keys
  if model.class.const_defined? :ERROR_FIELDS
    model.class.const_get(:ERROR_FIELDS).each do |f|
      h[f] = model.send(f)
    end
  end
  I18n.t key, h
end
