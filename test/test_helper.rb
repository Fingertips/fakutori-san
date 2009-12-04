TEST_ROOT_DIR = File.expand_path('..', __FILE__)
require 'test/unit'

frameworks = {
  'activesupport' => %w(active_support),
  'activerecord'  => %w(active_record),
  'actionpack'    => %w(action_controller)
}

rails = [
  File.expand_path('../../../rails', TEST_ROOT_DIR),
  File.expand_path('../../rails', TEST_ROOT_DIR)
].detect do |possible_rails|
  begin
    entries = Dir.entries(possible_rails)
    frameworks.keys.all? { |framework| entries.include?(framework) }
  rescue Errno::ENOENT
    false
  end
end
frameworks.keys.each { |framework| $:.unshift(File.join(rails, framework, 'lib')) }

$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')
$:.unshift TEST_ROOT_DIR

ENV['RAILS_ENV'] = 'test'

# Require Rails components
frameworks.values.flatten.each { |lib| require lib }
require File.expand_path('../../rails/init', __FILE__)

# Libraries for testing
require 'rubygems' rescue LoadError
require 'test/spec'
require 'mocha'

# Open a connection for ActiveRecord
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table :members do |t|
    t.string :name
    t.string :email
    t.string :password
  end
  
  create_table :articles do |t|
  end
end

# Require all models and factories used in the tests
Dir.glob(File.join(TEST_ROOT_DIR, 'models', '**', '*.rb')).each do |model|
  require model
end

Dir.glob(File.join(TEST_ROOT_DIR, 'factories', '**', '*.rb')).each do |factory|
  require factory
end