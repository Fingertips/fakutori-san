# = FakutoriSan
#
# As its description, FakutoriSan aims to be a lean model factory. As it uses
# vanilla Ruby to define the factories, you can use class inheritance and all
# other standard Ruby practices.
module FakutoriSan
  class FakutoriMissing < NameError; end
  
  # Returns a hash of the available <tt>model => factory</tt> pairs.
  def self.factories
    @factories ||= {}
  end
  
  module FakutoriExt
    def associate_to(model, options = nil)
      @__factory__.associate(self, model, options)
      self
    end
    
    def apply_scene(name, options = {})
      @__factory__.scene(name, self, options)
    end
  end
  
  class Collection < Array
    include FakutoriExt
    
    def initialize(factory, times)
      @__factory__ = factory
      super(times)
    end
    
    def factory
      @__factory__
    end
  end
  
  class Fakutori
    class << self
      def inherited(factory_klass)
        model_klass = Object.const_get(factory_klass.name.gsub(/^FakutoriSan::|Fakutori$/, ''))
        factory_klass.for_model model_klass
      rescue NameError
      end
      
      def for_model(model)
        FakutoriSan.factories[model] = new(model)
      end
    end
    
    attr_reader :model
    
    def initialize(model)
      @model = model
    end
    
    def plan_one(*type_and_or_attributes)
      type, attributes = type_and_attributes(type_and_or_attributes)
      m = "#{type}_attrs"
      
      if respond_to?(m)
        plan = method(m).arity.zero? ? send(m) : send(m, attributes)
        plan.merge(attributes)
      else
        raise NoMethodError, "#{self.class.name} has no attributes method for `#{name.inspect}'"
      end
    end
    
    def plan(*times_and_or_type_and_or_attributes)
      multiple_times :plan, times_and_or_type_and_or_attributes
    end
    
    def build_one(*type_and_or_attributes)
      instance = @model.new(plan_one(*type_and_or_attributes))
      instance.extend(FakutoriExt)
      instance.instance_variable_set(:@__factory__, self)
      instance
    end
    
    def build(*times_and_or_type_and_or_attributes)
      multiple_times :build, times_and_or_type_and_or_attributes
    end
    
    def create_one(*type_and_or_attributes_and_or_validate)
      args = type_and_or_attributes_and_or_validate
      
      validate = args.pop if BOOLS.include?(args.last)
      instance = build_one(*args)
      validate ? instance.save! : instance.save(false)
      instance
    end
    
    def create_one!(*type_and_or_attributes)
      type_and_or_attributes << true
      create_one(*type_and_or_attributes)
    end
    
    def create(*times_and_or_type_and_or_attributes)
      multiple_times :create, times_and_or_type_and_or_attributes
    end
    
    def create!(*times_and_or_type_and_or_attributes)
      times_and_or_type_and_or_attributes << true
      create(*times_and_or_type_and_or_attributes)
    end
    
    def associate(record_or_collection, to_model, options = nil)
      if builder = association_builder_for(to_model)
        [*record_or_collection].each do |record|
          send(*[builder, record, to_model, options].compact)
        end
      else
        raise NoMethodError, "#{self.class.name} has no association builder method for model `#{to_model.inspect}'."
      end
      
      record_or_collection
    end
    
    def scene(name, record_or_collection, options = {})
      method = "#{name}_scene"
      unless respond_to?(method)
        raise NoMethodError, "#{self.class.name} has no scene method for scene `#{name.inspect}'"
      end
      
      if record_or_collection.is_a?(Array)
        record_or_collection.each_with_index do |record, index|
          options[:index] = index
          send(method, record, options)
        end
      else
        send(method, record_or_collection, options)
      end
      
      record_or_collection
    end
    
    private
    
    BOOLS = [true, false]
    
    def type_and_attributes(args)
      attributes = args.extract_options!
      [args.pop || :valid, attributes]
    end
    
    def extract_times(args)
      args.shift if args.first.is_a?(Numeric)
    end
    
    def multiple_times(type, args)
      m = "#{type}_one"
      
      if times = extract_times(args)
        Collection.new(self, times) { send(m, *args) }
      else
        send(m, *args)
      end
    end
    
    def association_builder_for(model)
      klass = model.is_a?(Class) ? model : model.class
      name = "associate_to_#{klass.name.underscore.gsub('/', '_')}".to_sym
      name if respond_to?(name)
    end
  end
end

module Kernel
  def Fakutori(model)
    FakutoriSan.factories[model] || raise(FakutoriSan::FakutoriMissing, "No factory defined for model `#{model}'")
  end
  
  private :Fakutori
end