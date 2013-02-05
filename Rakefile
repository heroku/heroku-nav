require 'bundler/setup'

task :default => :spec

desc 'Run specs (with story style output)'
task 'spec' do
  sh 'bacon -s spec/*_spec.rb'
end
