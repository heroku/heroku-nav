Gem::Specification.new do |s|
  s.name = %q{heroku-nav}
  s.version = "0.1.24"
  s.date = "2011-10-10"

  s.rubygems_version = "1.3.6"
  s.required_rubygems_version = "1.3.6"
  s.authors = ["David Dollar", "Pedro Belo", "Raul Murciano", "Todd Matthews", "Jonathan Dance"]
  s.email = ["david@heroku.com", "pedro@heroku.com", "raul@heroku.com", "todd@heroku.com", "jd@heroku.com"]
  s.homepage = "http://github.com/heroku/heroku-nav"
  s.description = ""
  s.summary = ""
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = Dir.glob("{lib,spec}/**/*").concat([
    "README.md",
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
  ])
  s.require_paths = ["lib"]
  s.test_files = Dir.glob("spec/**/*").concat([
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
  ])

  s.specification_version = 3
  s.add_development_dependency(%q<bacon>, [">= 0"])
  s.add_development_dependency(%q<mocha>, [">= 0"])
  s.add_development_dependency(%q<sinatra>, [">= 0"])
  s.add_development_dependency(%q<rack-test>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_runtime_dependency(%q<rest-client>, [">= 1.0"])
  s.add_runtime_dependency(%q<json>, [">= 0"])
end
