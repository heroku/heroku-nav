task :default => :spec

desc 'Run specs (with story style output)'
task 'spec' do
  sh 'bacon -s spec/*_spec.rb'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "heroku-nav"
    gemspec.summary = ""
    gemspec.description = ""
    gemspec.email = "pedro@heroku.com"
    gemspec.homepage = "http://heroku.com"
    gemspec.authors = ["Todd Matthews", "Pedro Belo"]

    gemspec.add_development_dependency(%q<baconmocha>, [">= 0"])
    gemspec.add_development_dependency(%q<sinatra>, [">= 0"])
    gemspec.add_development_dependency(%q<rack-test>, [">= 0"])
    gemspec.add_dependency(%q<rest-client>, ["~> 1.2.0"])
    gemspec.add_dependency(%q<json>, [">= 0"])

    gemspec.version = '0.1.3'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
