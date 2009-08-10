# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fakutori-san}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-08-10}
  s.description = %q{FakutoriSan is a lean model factory plugin which uses vanilla Ruby to define the factories, allowing you to optimally use inheritance etc.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/fakutori_san.rb",
    "rails/init.rb",
    "test/fakutori_san_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/Fingertips/fakutori-san}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{FakutoriSan is a lean model factory plugin which uses vanilla Ruby to define the factories, allowing you to optimally use inheritance etc.}
  s.test_files = [
    "test/fakutori_san_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end