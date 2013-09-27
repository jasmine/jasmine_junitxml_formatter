require 'rails/railtie'

module JasmineJunitxmlFormatter
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'jasmine_junitxml_formatter/tasks/jasmine_junitxml_formatter.rake'
    end
  end
end


