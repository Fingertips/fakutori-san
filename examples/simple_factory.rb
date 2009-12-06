require 'faker' # For more information about Faker, see http://faker.rubyforge.org

# Always define your factories in the FakutoriSan module so they don't mix
# interfere with the rest of your code and FakutoriSan can find them.
module FakutoriSan
  # Factories always subclass from Fakutori
  class Article < Fakutori
    # When creating a new object, Fakutori-San will always use the valid_attrs method by default.
    def valid_attrs
      { :title => Faker::Lorem.words.join(' '), :body => Faker::Lorem.paragraphs.join("\n\n") }
    end
    
    def invalid_attrs
      { :title => '', :body => '' }
    end
  end
end

# After defining a factory you can plan, build, or create objects

# The plan method returns attributes from the factory
article_atributes = Fakutori(Article).plan
# The build method uses attributes from factory to instantiate an object
article = Fakutori(Article).build
# The create method builds the object and saves it
article = Fakutori(Article).create

# The plan, build, and create methods do smart things with their arguments.

# Use a different set of attributes to build
article = Fakutori(Article).build(:invalid)
# Override default attributes with your own custom ones
article = Fakutori(Article).build(:title => 'Breaking Bad')
# Build three articles
articles = Fakutori(Article).build(3)
# Build three invalid articles
articles = Fakutori(Article).build(3, :invalid)
# Build three invalid articles with a specified body
articles = Fakutori(Article).build(3, :invalid, :body => "Hi, I'm invalid") 