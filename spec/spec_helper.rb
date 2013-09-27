require 'rspec'
require 'jasmine_junitxml_formatter'

def in_temp_dir
  project_root = File.expand_path(File.join('..', '..'), __FILE__)
  Dir.mktmpdir do |tmp_dir|
    begin
      Dir.chdir tmp_dir
      yield tmp_dir, project_root
    ensure
      Dir.chdir project_root
    end
  end
end

def passing_raw_result
  {'id' => 123, 'status' => 'passed', 'fullName' => 'Passing test', 'description' => 'Passing', 'failedExpectations' => []}
end

def pending_raw_result
  {'id' => 123, 'status' => 'pending', 'fullName' => 'Passing test', 'description' => 'Pending', 'failedExpectations' => []}
end

def failing_raw_result
  {
    'status' => 'failed',
    'id' => 124,
    'description' => 'a failing spec',
    'fullName' => 'a suite with a failing spec',
    'failedExpectations' => [
      {
        'message' => 'a failure message',
        'stack' => 'a stack trace'
      }
    ]
  }
end

