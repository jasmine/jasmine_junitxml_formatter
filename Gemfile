source 'https://rubygems.org'

gemspec

if ENV['TRAVIS']
  gem 'jasmine', :git => 'https://github.com/pivotal/jasmine-gem.git', :branch => 'main'
else
  gem 'jasmine', :path => '../jasmine-gem'
end

gem 'rack'
