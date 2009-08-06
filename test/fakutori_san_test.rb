require File.expand_path('../test_helper', __FILE__)

class Member < ActiveRecord::Base
end

class Article < ActiveRecord::Base
end

module FakutoriSan
  class Member < Fakutori
    def default
      { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
    end
  end
  
  class Foo < Fakutori
    for_model Article
  end
end

describe "FakutoriSan::Fakutori, concerning setup" do
  it "should automatically find the model class based on the factory class's name and initialize an instance the factory subclass" do
    factory = FakutoriSan.factories[Member]
    factory.should.be.instance_of FakutoriSan::Member
    factory.model.should.be Member
  end
  
  it "should allow a user to explicitly define the model class when automatically finding the right class fails" do
    factory = FakutoriSan.factories[Article]
    factory.should.be.instance_of FakutoriSan::Foo
    factory.model.should.be Article
  end
end

describe "FakutoriSan::Fakutori, concerning `plans'" do
  it "should return a hash of attributes" do
    Fakutori(Member).plan_one.should == { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
  end
  
  it "should return an array attribute hashes" do
    Fakutori(Member).plan(2).should == [
      { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' },
      { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
    ]
  end
end

describe "FakutoriSan::Fakutori, concerning `building'" do
  it "should build one instance with the default plan" do
    instance = Fakutori(Member).build_one
    instance.should.be.new_record
    instance.attributes.should == Fakutori(Member).plan_one
  end
  
  it "should return an of instances build with the default plan" do
    instances = Fakutori(Member).build(2)
    instances.each do |instance|
      instance.should.be.new_record
      instance.attributes.should == Fakutori(Member).plan_one
    end
  end
end

describe "FakutoriSan::Fakutori, concerning `creating'" do
  it "should create one instance with the default plan" do
    instance = Fakutori(Member).create_one
    instance.should.not.be.new_record
    instance.attributes.except('id').should == Fakutori(Member).plan_one
  end
  
  it "should return an of instances build with the default plan" do
    instances = Fakutori(Member).create(2)
    instances.each do |instance|
      instance.should.not.be.new_record
      instance.attributes.except('id').should == Fakutori(Member).plan_one
    end
  end
end

describe "The top level Fakutori method" do
  it "should return the factory belonging to the given model" do
    Fakutori(Member).should.be FakutoriSan.factories[Member]
    Fakutori(Article).should.be FakutoriSan.factories[Article]
  end
end