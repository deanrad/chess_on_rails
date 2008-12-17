# Enable this extension so we can parse the spec files

# If desired set this variable to use our own rspec-like DSL
unless ENV['MOCK_RSPEC'] == "1"
  require 'spec'
  require 'mocha'
end

# load our models - baseclasses first 
# note Dir.glob indeterministic order on different OS - so hacking the load order here
load 'spec/mocks/chess_fixtures.rb'
load 'sides.rb'
load 'piece.rb'
load 'match.rb'
load 'move.rb'
load 'player.rb'
%w{ spec/mocks app/models app/models/pieces }.each do |dir|
  full_path = File.expand_path(File.dirname(__FILE__) + "/../#{dir}/*.rb")
  Dir.glob( full_path ).each do |f| 
    load f
  end
end

class Object
  if ENV['MOCK_RSPEC']
    def describe name, *args, &block
      class_name = name.gsub ' ', ''
      eval "module Specs; class #{class_name} < Expectorant; end; end"
      eval "Specs::#{class_name}.class_eval &block"
      #klass = Object.const_get "Specs::#{class_name}"
      #klass.class_eval &block
    end
  end
end
class Expectorant
  class << self
    def it name, *args, &block
      unless block_given?
        logger.PENDING "test #{name} not implemented yet."
        return
      end
      meth_name = name.gsub ' ', '_'
      define_method meth_name, &block
    end
  end
end


### include names 
#load 'spec/models/active_record_mock.spec'
#load 'spec/models/chess_mock.spec'


# A class, returned by .should on any object which can do comparisons to the expected results passed
class Expecter
  def initialize( whoiam )
    @whoiam = whoiam
  end
  def == expected
    @whoiam_expected_to_be = expected
    if @whoiam==@whoiam_expected_to_be
      logger.PASS "#{@whoiam} == #{@whoiam_expected_to_be}" 
    else
      logger.FAIL "#{@whoiam} not == #{@whoiam_expected_to_be}" 
    end
  end
end

#hook so we can invoke a spec in an irb session
class Object
  if ENV['MOCK_RSPEC']=="1"
    @@spec_classes = [Specs::ActiveRecordMockSpec,
      Specs::ChessMockSpec,
    ] #, AnyMockSpecification]
    def spec name
      #search for and invoke spec by that name
      @@spec_classes.each do |spec_class|
        specer = spec_class.new
        name = name.to_s if name.kind_of? Symbol  
        name.gsub!( /[- ]/, '_')
        if specer.respond_to? name
          specer.send name 
          return
        end
      end
      logger.error "Test #{name} not found in #{@@spec_classes.join ','}" 
    end
    def should
      Expecter.new( self )
    end
    ### run all our tests ###
    @@spec_classes.map{ |c| c.new }.each do |specer|
      (specer.methods - Object.methods).each do |example|
        logger.testing "#{specer.class.name}.#{example}"
        specer.send example
      end
    end

  else
    #run all specs in spec\models
    def spec_all
      Spec::Runner::CommandLine.run(
        Spec::Runner::OptionParser.parse(
	   [File.expand_path( File.join( File.dirname( __FILE__), '/models') ),
          '-p', '**/*spec*'
          ], $stderr, $stdout
        )
      )
    end
    #use real rspec to run the example by the name given in ANY of the spec files in spec\models
    def spec name
      Spec::Runner::CommandLine.run(
        Spec::Runner::OptionParser.parse(
	   [File.expand_path( File.join( File.dirname( __FILE__), '/models') ),
          '-p', '**/*spec*',
           '-e', name
          ], $stderr, $stdout
        )
      )
    end
  end
end




