require File.expand_path('../test_helper', __FILE__)

describe "FakutoriSan" do
  it "should define a method on kernel to create factories" do
    fakutori = Fakutori(Member)
    fakutori.model.should == Member
  end
end