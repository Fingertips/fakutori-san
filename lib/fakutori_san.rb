module FakutoriSan
  class << self
    def factories
      @factories ||= {}
    end
  end
  
  class Fakutori
    class << self
      def inherited(factory_klass)
        factory_klass.for_model Object.const_get(factory_klass.name.sub(/^FakutoriSan::/, ''))
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
      type, attributes = extract_type_and_attributes(type_and_or_attributes)
      send(type).merge(attributes)
    end
    
    def plan(*times_and_or_type_and_or_attributes)
      args = times_and_or_type_and_or_attributes
      
      if times = extract_times(args)
        Array.new(times) { plan_one(*args) }
      else
        plan_one(*args)
      end
    end
    
    def build_one(*type_and_or_attributes)
      @model.new(plan_one(*type_and_or_attributes))
    end
    
    def build(*times_and_or_type_and_or_attributes)
      args = times_and_or_type_and_or_attributes
      
      if times = extract_times(args)
        Array.new(times) { build_one(*args) }
      else
        build_one(*args)
      end
    end
    
    BOOLS = [true, false]
    
    # type:
    # attributes:
    # validate:
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
      args = times_and_or_type_and_or_attributes
      
      if times = extract_times(args)
        Array.new(times) { create_one(*args) }
      else
        create_one(*args)
      end
    end
    
    def create!(*args)
      args << true
      create(*args)
    end
    
    private
    
    def extract_type_and_attributes(args)
      attributes = args.extract_options!
      type = args.pop || :default
      [type, attributes]
    end
    
    def extract_times(args)
      args.shift if args.first.is_a?(Numeric)
    end
  end
end

def Fakutori(model)
  FakutoriSan.factories[model]
end