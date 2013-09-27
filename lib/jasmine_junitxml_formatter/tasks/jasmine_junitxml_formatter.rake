namespace :jasmine_junitxml_formatter do
  task :setup do
    require File.join('jasmine_junitxml_formatter', 'configure_jasmine')
  end
end

task 'jasmine:require' => ['jasmine_junitxml_formatter:setup']

