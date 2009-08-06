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
    
    def plan_one(options = {})
      options[:type] ||= :default
      send(options[:type])
    end
    
    def plan(times = nil, options = {})
      if times
        Array.new(times) { plan_one(options) }
      end
    end
    
    def build_one(options = {})
      @model.new(plan_one(options))
    end
    
    def build(times = nil, options = {})
      if times
        Array.new(times) { build_one(options) }
      end
    end
    
    def create_one(options = {})
      instance = build_one(options)
      instance.save
      instance
    end
    
    def create(times = nil, options = {})
      if times
        Array.new(times) { create_one(options) }
      end
    end
  end
end

def Fakutori(model)
  FakutoriSan.factories[model]
end