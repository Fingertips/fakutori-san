module FakutoriSan
  def self.factories
    @factories ||= {}
  end
  
  class Collection < Array
    attr_reader :factory
    
    def initialize(factory, times)
      @factory = factory
      super(times)
    end
    
    def associate_to(model, options = nil)
      each { |record| @factory.associate(record, model, options) }
    end
  end
  
  module AssociateTo
    def associate_to(model, options = nil)
      @__factory__.associate(self, model, options)
    end
  end
  
  class Fakutori
    class << self
      def inherited(factory_klass)
        factory_klass.for_model Object.const_get(factory_klass.name.sub(/^FakutoriSan::/, '')) rescue NameError
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
      send(type).merge(attributes)
    end
    
    def plan(*times_and_or_type_and_or_attributes)
      multiple_times :plan, times_and_or_type_and_or_attributes
    end
    
    def build_one(*type_and_or_attributes)
      instance = @model.new(plan_one(*type_and_or_attributes))
      instance.extend(AssociateTo)
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
    
    def associate(record, to_model, options = nil)
      if builder = association_builder_for(to_model)
        if options
          send(builder, record, to_model, options)
        else
          send(builder, record, to_model)
        end
      else
        raise NoMethodError, "#{self.class.name} has no association builder defined for given model `#{to_model.inspect}'."
      end
    end
    
    private
    
    BOOLS = [true, false]
    
    def type_and_attributes(args)
      attributes = args.extract_options!
      [args.pop || :default, attributes]
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
    FakutoriSan.factories[model]
  end
  
  private :Fakutori
end