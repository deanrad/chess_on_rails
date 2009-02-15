require 'association_store'

module ActiveRecord
  class Base
    # logger.info "loaded fake #{self}"

    def included(other)
      # logger.info "looks like #{other} is being extended by fake AR now, eh ?"
    end

    # Hash-based Initializer
    def initialize( opts = {} )
      opts.each do |k,v|
        self.instance_variable_set "@#{k}", v
      end
    end

    def [] (key)
      return instance_variable_get("@#{key}") if instance_variables.include? "@#{key}"
    end

    def []= (key, val)
      return instance_variable_set("@#{key}", val) #if instance_variables.include? "@#{key}"
    end
    
    def errors
      @errors ||= Errors.new
    end
    
    def valid?
      do_validate unless @validated
      errors.length == 0
    end
    
    # Do validate is a method of ActiveRecord::Base that calls all the validation callbacks in the
    # proper order. do_save is a friend of its and common functionality may be factored out of them
    # in the future
    def do_validate
      @validated = true
      bvs = self.class.class_eval( "@@before_validators" ) rescue []
      bvs.each do |bv|
        result = self.send bv if self.respond_to? bv
        return false unless valid?
      end
      rvs = self.class.class_eval("@@real_validators") rescue []
      rvs.each do |rv|
        result = self.send rv if self.respond_to? rv
        return false unless valid?
      end
      avs = self.class.class_eval("@@after_validators") rescue []
      avs.each do |av|
        result = self.send av if self.respond_to? av
      end
      
      true
    end
    
    # does a noop on an object if its valid 
    # TODO save should give it an ID - possibly its object_id ?
    def save
      if !valid?
        return false
      end
      do_save
      true
    end
    
    def do_save
      bss = self.class.class_eval( "@@before_savers" ) rescue []
      bss.each do |bs|
        if self.respond_to? bs
            result = self.send( bs ) rescue false
          end
      end
      ass = self.class.class_eval( "@@after_savers" ) rescue []
      ass.each do |as|
        if self.respond_to? as
          result = self.send( as ) rescue false
        end
      end
    end
    
    def reload; self; end

    # tries to act as 1) instance variable accesssor...
=begin
    def method_missing name, *args
      # logger.info "#{name}"
      return nil
    end
    def method_missing name, *args
      name = name.to_s
      # logger.info "#{name}"
      if instance_variables.include? "@#{name.sub /\w+=/, ''}"
        return instance_variable_set("@#{name.sub '=', ''}", args[0]) if name =~ /\w+=/
        return instance_variable_get("@#{name}")
      end
    end
=end
    
    class Errors < Hash
      def add_to_base msg
        add :base, msg
      end
      def add field, msg
        self[field] ||= []
        self[field] << msg
        # logger.validation "#{field}:#{msg}"
      end
    end
    
    class << self
      
      # Fake has_many adds accessors for an array-like property which begins as an empty array
      def has_many symname, *args
        assoc = symname.to_s
        me = self 

        class_eval do
          define_method "#{assoc}" do
            unless instance_variable_get "@#{assoc}"
              as = AssociationStore.new( self, args )
              instance_variable_set "@#{assoc}", as
            end
            instance_variable_get "@#{assoc}"
          end
          #dont provide a setter or our smart associationstore object could get replaced
        end        
        fake_mm #for now just shoehorn this in with either has_many or belongs_to
      end

      # the method_missing implementation added to the derived class
      def fake_mm
        class_eval do
          define_method :method_missing do |name, *args|
            #possibly resolve via instance_variable_get "@#{name}"
            # logger.info "got message #{name} that we weren't ready for"
          end
        end
      end
      
      # Fake belongs_to adds accessors for a simple property which begins as nil    
      def belongs_to symname, *args
        assoc = symname.to_s
        class_eval do
          attr_accessor "#{assoc}"
        end
        
        fake_mm #for now just shoehorn this in with either has_many or belongs_to
      end

      # after_save and friends each get a class variable into which the names of 
      #  such callbacks are placed. during the appropriate times of hte lifecycle
      #  these methods are called - see do_validate and do_save in this file
      def after_save *args
        after_savers ||= []
        args.each{ |a| after_savers << a }
        class_eval do
          class_variable_set "@@after_savers", after_savers
        end
        # logger.info "appended #{args} as after_savers"
      end
    
      def before_validation *args
        before_validators ||= []
        args.each{ |a| before_validators << a }
        class_eval do
          class_variable_set "@@before_validators", before_validators
        end
        # logger.info "appended #{args} as pre-validators"
      end
      def after_validation  *args
        after_validators ||= []
        args.each{ |a| after_validators << a }
        class_eval do
          class_variable_set "@@after_validators", after_validators
        end
      end
      def validate *args; 
        real_validators ||= []
        args.each{ |a| real_validators << a }
        class_eval do
          class_variable_set "@@real_validators", real_validators
        end
      end
      def validates_presence_of *args; end
      def validates_length_of *args; end
      def method_missing name, *args
        # logger.info "ActiveRecord::Base.#{name} referred to but not mocked out"
      end
    end
  end
end
