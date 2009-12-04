require 'fakutori_san/fakutori'

# = FakutoriSan
#
# As its description, FakutoriSan aims to be a lean model factory. As it uses
# vanilla Ruby to define the factories, you can use class inheritance and all
# other standard Ruby practices.
module FakutoriSan
end

module Kernel
  def Fakutori(model)
    FakutoriSan.factories[model] || raise(FakutoriSan::FakutoriMissing, "No factory defined for model `#{model}'")
  end
  private :Fakutori
end