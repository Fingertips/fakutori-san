require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the fakutori-san plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the fakutori-san plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Fakutori-san'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=utf8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "fakutori-san"
    s.homepage = "http://github.com/Fingertips/fakutori-san"
    s.email    = "eloy.de.enige@gmail.com"
    s.authors  = ["Eloy Duran"]
    s.summary  = s.description = "FakutoriSan is a lean model factory plugin which uses vanilla Ruby to define the factories, allowing you to optimally use inheritance etc."
  end
rescue LoadError
end
 
begin
  require 'jewelry_portfolio/tasks'
  JewelryPortfolio::Tasks.new do |p|
    p.account = 'Fingertips'
  end
rescue LoadError
end