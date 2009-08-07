require File.expand_path('../test_helper', __FILE__)

class Member < ActiveRecord::Base
  validates_presence_of :name
end

class Article < ActiveRecord::Base
end

module FakutoriSan
  class Member < Fakutori
    def default
      { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
    end
    
    def minimal
      { 'name' => 'Eloy' }
    end
    
    def invalid
      {}
    end
  end
  
  class Foo < Fakutori
    for_model Article
  end
end

module SharedSpecsHelper
  def define_collection_specs_for(type)
    it "should call ##{type}_one multiple times and return an array of the resulting attribute hashes" do
      attributes = { 'name' => 'Eloy' }
      
      @factory.expects("#{type}_one").with(attributes).times(2).returns({})
      @factory.send(type, 2, attributes).should == [{}, {}]
      
      @factory.expects("#{type}_one").with(:minimal, attributes).times(2).returns({})
      @factory.send(type, 2, :minimal, attributes).should == [{}, {}]
    end
    
    it "should not call ##{type}_one multiple times if no `times' argument is given" do
      attributes = { 'name' => 'Eloy' }
      
      @factory.expects("#{type}_one").with(attributes).times(1).returns({})
      @factory.send(type, attributes).should == {}
      
      @factory.expects("#{type}_one").with(:minimal, attributes).times(1).returns({})
      @factory.send(type, :minimal, attributes).should == {}
    end
    
    it "should return a FakutoriSan::Collection instance when a collection is created" do
      collection = @factory.send(type, 2)
      collection.should.be.instance_of FakutoriSan::Collection
      collection.factory.should.be @factory
    end
  end
end
Test::Unit::TestCase.send(:extend, SharedSpecsHelper)

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

describe "The top level Fakutori method" do
  it "should return the factory belonging to the given model" do
    Fakutori(Member).should.be FakutoriSan.factories[Member]
    Fakutori(Article).should.be FakutoriSan.factories[Article]
  end
end

describe "FakutoriSan::Fakutori, concerning `planning'" do
  before do
    @factory = Fakutori(Member)
  end
  
  define_collection_specs_for :plan
  
  it "should return a hash of attributes" do
    @factory.plan_one.should == { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
  end
  
  it "should merge the given attributes onto the resulting attributes hash" do
    @factory.plan_one('name' => 'Alloy', 'password' => 'supersecret').should ==
      { 'name' => 'Alloy', 'email' => 'eloy@example.com', 'password' => 'supersecret' }
  end
  
  it "should take an optional first plan `type', which invokes the method by the same name" do
    @factory.plan_one(:minimal).should == { 'name' => 'Eloy' }
    @factory.plan_one(:minimal, 'email' => 'eloy@example.com').should == { 'name' => 'Eloy', 'email' => 'eloy@example.com' }
  end
end

describe "FakutoriSan::Fakutori, concerning `building'" do
  before do
    @factory = Fakutori(Member)
  end
  
  define_collection_specs_for :build
  
  it "should build one instance with the default plan" do
    instance = @factory.build_one
    instance.should.be.new_record
    instance.attributes.should == @factory.plan_one
  end
  
  it "should take an optional first plan `type', which invokes the method by the same name" do
    instance = @factory.build_one(:minimal)
    instance.should.be.new_record
    instance.attributes.except('password', 'email').should == @factory.plan_one(:minimal)
    
    instance = @factory.build_one(:minimal, 'email' => 'eloy@example.com')
    instance.should.be.new_record
    instance.attributes.except('password').should == @factory.plan_one(:minimal, 'email' => 'eloy@example.com')
  end
end

describe "FakutoriSan::Fakutori, concerning `creating'" do
  before do
    @factory = Fakutori(Member)
  end
  
  define_collection_specs_for :create
  
  it "should create one instance with the default plan" do
    instance = @factory.create_one
    instance.should.not.be.new_record
    instance.attributes.except('id').should == @factory.plan_one
  end
  
  it "should not perform validations by default" do
    instance = @factory.create_one(:invalid)
    instance.should.not.be.new_record
    instance.should.not.be.valid
  end
  
  it "should take an optional first plan `type', which invokes the method by the same name" do
    instance = @factory.create_one(:minimal)
    instance.should.not.be.new_record
    instance.attributes.except('id', 'password', 'email').should == @factory.plan_one(:minimal)
    
    instance = @factory.create_one(:minimal, 'email' => 'eloy@example.com')
    instance.should.not.be.new_record
    instance.attributes.except('id', 'password').should == @factory.plan_one(:minimal, 'email' => 'eloy@example.com')
  end
  
  it "should perform validations and raise an exception if created with #create_one!" do
    lambda {
      @factory.create_one!(:invalid)
    }.should.raise ActiveRecord::RecordInvalid
    
    lambda {
      instance = @factory.create_one!(:minimal, 'password' => '12345')
      instance.attributes.except('id', 'email').should == @factory.plan_one(:minimal, 'password' => '12345')
    }.should.not.raise ActiveRecord::RecordInvalid
  end
  
  it "should call #create_one multiple times and perform validations, and return an array of the resulting record instances" do
    attributes = { 'name' => 'Eloy' }
    
    @factory.expects(:create_one).with(attributes, true).times(2).returns({})
    @factory.create!(2, attributes)
    
    @factory.expects(:create_one).with(:minimal, attributes, true).times(2).returns({})
    @factory.create!(2, :minimal, attributes)
  end
end

describe "FakutoriSan::Collection, concerning associating records" do
  before do
    @factory = Fakutori(Member)
    @collection = @factory.create!(2)
  end
  
  it "should call #associate on each member and forward the given model and arguments" do
    attributes = { 'name' => 'Eloy' }
    @collection.each { |record| @factory.expects(:associate).with(record, Article, attributes) }
    @collection.associate_to(Article, attributes)
  end
  
  it "should return itself after associating so the user can chain calls" do
    @factory.stubs(:associate)
    @collection.associate_to(Article, {}).should.be @collection
  end
end