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
      attributes = type_and_or_attributes.extract_options!
      type = type_and_or_attributes.pop || :valid
      m = "#{type}_attrs"
      
      if respond_to?(m)
        plan = method(m).arity.zero? ? send(m) : send(m, attributes)
        plan.merge(attributes)
      else
        raise NoMethodError, "#{self.class.name} has no attributes method for type `#{type}'"
      end
    end
    
    def plan(*times_and_or_type_and_or_attributes)
      multiple_times :plan, times_and_or_type_and_or_attributes
    end
    
    def build_one(*type_and_or_attributes)
      make_chainable(@model.new(plan_one(*type_and_or_attributes)))
    end
    
    def build(*times_and_or_type_and_or_attributes)
      multiple_times :build, times_and_or_type_and_or_attributes
    end
    
    def create_one(*type_and_or_attributes_and_or_validate)
      args = type_and_or_attributes_and_or_validate
      
      validate = args.pop if [true, false].include?(args.last)
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
    
    def make_chainable(instance)
      instance.extend(FakutoriExt)
      instance.instance_variable_set(:@__factory__, self)
      instance
    end
    
    def multiple_times(type, args)
      m = "#{type}_one"
      
      if args.first.is_a?(Numeric)
        Collection.new(self, args.shift) { send(m, *args) }
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