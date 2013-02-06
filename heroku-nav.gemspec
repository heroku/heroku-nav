Gem::Specification.new do |s|
  s.name = %q{heroku-nav}
  s.version = "0.2.2"
  s.date = "2013-02-05"

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
  s.add_development_dependency("rake", [">= 0"])
  s.add_development_dependency("bacon", [">= 0"])
  s.add_development_dependency("mocha", [">= 0"])
  s.add_development_dependency("sinatra", [">= 0"])
  s.add_development_dependency("rack-test", [">= 0"])
  s.add_development_dependency("webmock", [">= 0"])
end
