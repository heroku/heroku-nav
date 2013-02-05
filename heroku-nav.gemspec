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
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "heroku-nav.gemspec",
    "lib/heroku/nav.rb",
    "spec/api_spec.rb",
    "spec/base.rb",
    "spec/nav_spec.rb",
  ]
  s.homepage = %q{http://heroku.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{}
  s.test_files = [
    "spec/api_spec.rb",
    "spec/base.rb",
    "spec/nav_spec.rb",
    "Gemfile",
    "Gemfile.lock",
  ]

  s.specification_version = 3
  s.add_development_dependency(%q<bacon>, [">= 0"])
  s.add_development_dependency(%q<mocha>, [">= 0"])
  s.add_development_dependency(%q<sinatra>, [">= 0"])
  s.add_development_dependency(%q<rack-test>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_runtime_dependency(%q<rest-client>, [">= 1.0"])
  s.add_runtime_dependency(%q<json>, [">= 0"])
end
