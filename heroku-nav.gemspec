Gem::Specification.new do |s|
  s.name = %q{heroku-nav}
  s.version = "0.1.24"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Dollar", "Pedro Belo", "Raul Murciano", "Todd Matthews"]
  s.date = %q{2011-10-10}
  s.description = %q{}
  s.email = ["david@heroku.com", "pedro@heroku.com", "raul@heroku.com", "todd@heroku.com"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "README.md",
    "Rakefile",
    "heroku-nav.gemspec",
    "lib/heroku/nav.rb",
    "spec/api_spec.rb",
    "spec/base.rb",
    "spec/nav_spec.rb"
  ]
  s.homepage = %q{http://heroku.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{}
  s.test_files = [
    "spec/api_spec.rb",
    "spec/base.rb",
    "spec/nav_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<baconmocha>, [">= 0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 1.0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<baconmocha>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 1.0"])
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<baconmocha>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 1.0"])
    s.add_dependency(%q<json>, [">= 0"])
  end
end

