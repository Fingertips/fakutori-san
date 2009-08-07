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
    
    def plan(times = nil, *type_and_or_attributes)
      if times
        Array.new(times) { plan_one(*type_and_or_attributes) }
      end
    end
    
    def build_one(*type_and_or_attributes)
      @model.new(plan_one(*type_and_or_attributes))
    end
    
    def build(times = nil, *type_and_or_attributes)
      if times
        Array.new(times) { build_one(*type_and_or_attributes) }
      end
    end
    
    def create_one(*type_and_or_attributes)
      instance = build_one(*type_and_or_attributes)
      instance.save(false)
      instance
    end
    
    def create(times = nil, *type_and_or_attributes)
      if times
        Array.new(times) { create_one(*type_and_or_attributes) }
      end
    end
    
    private
    
    def extract_type_and_attributes(args)
      attributes = args.extract_options!
      type = args.first || :default
      [type, attributes]
    end
  end
end

def Fakutori(model)
  FakutoriSan.factories[model]
end