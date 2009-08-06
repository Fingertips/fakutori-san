TEST_ROOT_DIR = File.expand_path('..', __FILE__)
require 'test/unit'

frameworks = %w(activesupport activerecord actionpack)

rails = [
  File.expand_path('../../../rails', TEST_ROOT_DIR),
  File.expand_path('../../rails', TEST_ROOT_DIR)
].detect do |possible_rails|
  begin
    entries = Dir.entries(possible_rails)
    frameworks.all? { |framework| entries.include?(framework) }
  rescue Errno::ENOENT
    false
  end
end

frameworks.each { |framework| $:.unshift(File.join(rails, framework, 'lib')) }
$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')
$:.unshift TEST_ROOT_DIR

ENV['RAILS_ENV'] = 'test'

# Rails libs
frameworks.each { |framework| require framework }
require File.expand_path('../../rails/init', __FILE__)

# Libraries for testing
require 'rubygems' rescue LoadError
require 'test/spec'
require 'mocha'

# Open a connection for ActiveRecord
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table :members do |t|
    t.string :name
    t.string :email
    t.string :password
  end
end