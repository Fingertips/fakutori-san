require File.expand_path('../test_helper', __FILE__)

module SharedSpecsHelper
  def define_shared_specs_for(type)
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
    
    unless type == :plan
      it "should extend each instance returned by FakutoriSan with the FakutoriSan::FakutoriExt module" do
        instance = @factory.create_one
        FakutoriSan::FakutoriExt.instance_methods.each do |method|
          instance.should.respond_to method
        end
      end
    end
  end
end
Test::Unit::TestCase.send(:extend, SharedSpecsHelper)

describe "FakutoriSan::Fakutori, concerning setup" do
  it "should automatically find the model class based on the factory class's name and initialize an instance the factory subclass" do
    factory = FakutoriSan.factories[Member]
    factory.should.be.instance_of FakutoriSan::MemberFakutori
    factory.model.should.be Member
  end
  
  it "should allow a user to explicitly define the model class when automatically finding the right class fails" do
    factory = FakutoriSan.factories[Article]
    factory.should.be.instance_of FakutoriSan::FooFakutori
    factory.model.should.be Article
  end
end

describe "The top level Fakutori method" do
  it "should return the factory belonging to the given model" do
    Fakutori(Member).should.be FakutoriSan.factories[Member]
    Fakutori(Article).should.be FakutoriSan.factories[Article]
  end
  
  it "should raise a FakutoriSan::FakutoriMissing exception if no factory can be found" do
    lambda {
      Fakutori(Unrelated)
    }.should.raise FakutoriSan::FakutoriMissing
  end
end

describe "FakutoriSan::Fakutori, concerning `planning'" do
  before do
    @factory = Fakutori(Member)
  end
  
  define_shared_specs_for :plan
  
  it "should return a hash of attributes" do
    @factory.plan_one.should == { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
  end
  
  it "should merge the given attributes onto the resulting attributes hash" do
    @factory.plan_one('name' => 'Alloy', 'password' => 'supersecret').should ==
      { 'name' => 'Alloy', 'email' => 'eloy@example.com', 'password' => 'supersecret' }
  end
  
  it "should pass the attributes hash to the `plan' method" do
    @factory.plan_one(:with_arg, 'name' => 'Eloy').should ==
      { 'name' => 'Eloy', 'arg' => { 'name' => 'Eloy' } }
  end
  
  it "should take an optional first plan `type', which invokes the method by the same name" do
    @factory.plan_one(:minimal).should == { 'name' => 'Eloy' }
    @factory.plan_one(:minimal, 'email' => 'eloy@example.com').should == { 'name' => 'Eloy', 'email' => 'eloy@example.com' }
  end
  
  it "should raise a NoMethodError if given a attributes type for which no method exists" do
    lambda { @factory.plan_one(:unexisting) }.should.raise NoMethodError
  end
end

describe "FakutoriSan::Fakutori, concerning `building'" do
  before do
    @factory = Fakutori(Member)
  end
  
  define_shared_specs_for :build
  
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
  
  define_shared_specs_for :create
  
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

describe "FakutoriSan::Fakutori, concerning associating records" do
  before do
    @factory = Fakutori(Member)
    @record = @factory.create_one
  end
  
  it "should return the association builder method if it exists for the given model" do
    @factory.send(:association_builder_for, Article).should == :associate_to_article
    @factory.send(:association_builder_for, Article.new).should == :associate_to_article
    
    @factory.send(:association_builder_for, Namespaced::Article).should == :associate_to_namespaced_article
    @factory.send(:association_builder_for, Namespaced::Article.new).should == :associate_to_namespaced_article
  end
  
  it "should return nil if no association builder method can be found for the given model" do
    @factory.send(:association_builder_for, Unrelated).should == nil
    @factory.send(:association_builder_for, Unrelated.new).should == nil
  end
  
  it "should call a builder method if it exists for the given model class" do
    options = {}
    @factory.expects(:associate_to_article).with(@record, Article, options)
    @factory.associate(@record, Article, options).should.be @record
  end
  
  it "should call a builder method for each member of a collection" do
    options = {}
    collection = @factory.create(2)
    
    @factory.expects(:associate_to_article).with(collection.first, Article, options)
    @factory.expects(:associate_to_article).with(collection.last, Article, options)
    @factory.associate(collection, Article, options).should.be collection
  end
  
  it "should raise an NoMethodError if an association builder method doesn't exist for a given model" do
    lambda {
      @factory.associate(@record, Unrelated, {})
    }.should.raise NoMethodError
  end
  
  it "should only forward the options hash if it's given by the user" do
    @factory.expects(:associate_to_article).with(@record, Article)
    @factory.associate(@record, Article)
  end
end

describe "FakutoriSan::Collection, concerning associating records" do
  before do
    @factory = Fakutori(Member)
    @collection = @factory.create!(2)
  end
  
  it "should call #associate on each member and forward the given model and arguments" do
    options = { 'name' => 'Eloy' }
    @factory.expects(:associate).with(@collection, Article, options)
    @collection.associate_to(Article, options)
  end
  
  it "should return itself after associating so the user can chain calls" do
    @collection.associate_to(Article, {}).should.be @collection
  end
  
  it "should forward the options as `nil' by default" do
    @factory.expects(:associate).with(@collection, Article, nil)
    @collection.associate_to(Article)
  end
end

describe "FakutoriSan::Fakutori, concerning `scenes'" do
  before do
    @factory = Fakutori(Member)
  end
  
  it "should invoke a scene method if it exists and return self" do
    instance = @factory.create_one
    @factory.scene(:with_name, instance, :name => 'Alloy').should == instance
    instance.name.should == 'Alloy'
  end
  
  it "should invoke a scene method for each record in a collection, assign the index to the options, and return self" do
    collection = @factory.create!(2)
    @factory.scene(:with_name, collection, :name => 'Alloy').should == collection
    collection.each_with_index do |record, index|
      record.reload.name.should == "Alloy#{index}"
    end
  end
  
  it "should raise a NoMethodError if a requested scene does not exist" do
    lambda {
      @factory.scene(:does_not_exist, @factory.build_one)
    }.should.raise NoMethodError
  end
end

describe "FakutoriSan::Collection, concerning `scenes'" do
  before do
    @factory = Fakutori(Member)
    @collection = @factory.create!(2)
  end
  
  it "should call Fakutori#scene with the given scene name, itself, and options" do
    @collection.apply_scene(:with_name, :name => 'Alloy')
    @collection.each do |record|
      record.reload.name.should.match /^Alloy/
    end
  end
end

describe "FakutoriSan::FakutoriExt" do
  before do
    @factory = Fakutori(Member)
  end
  
  it "should call Fakutori#associate with the record and options given and return itself" do
    instance = @factory.create_one
    
    @factory.expects(:associate).with(instance, Article, nil)
    instance.associate_to(Article).should.be instance
    
    options = {}
    @factory.expects(:associate).with(instance, Article, options)
    instance.associate_to(Article, options).should.be instance
  end
  
  it "should call Fakutori#scene with the record and options given" do
    instance = @factory.create_one
    instance.apply_scene(:with_name).reload.name.should == ''
    instance.apply_scene(:with_name, :name => 'Alloy').reload.name.should == 'Alloy'
  end
end