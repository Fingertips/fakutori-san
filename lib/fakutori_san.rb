require 'fakutori_san/fakutori'

# FakutoriSan is the module where most of the implementation resides.
module FakutoriSan
end

module Kernel
  # The Fakutori method is used to instantiate your factories. For more information about defining
  # and using factories see FakutoriSan::Fakutori and the examples.
  def Fakutori(model)
    FakutoriSan.factories[model] || raise(FakutoriSan::FakutoriMissing, "No factory defined for model `#{model}'")
  end
  private :Fakutori
end