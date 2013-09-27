require 'jasmine'
require 'jasmine/formatters/junit_xml'

Jasmine.configure do |config|
  config.formatters << Jasmine::Formatters::JunitXml
end
