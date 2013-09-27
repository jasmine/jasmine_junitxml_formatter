require 'spec_helper'
require 'nokogiri'

describe Jasmine::Formatters::JunitXml do

  class FakeFile
    def initialize
      @content = ''
    end

    attr_reader :content

    def puts(content)
      @content << content
    end
  end

  let(:file_stub) { FakeFile.new }

  describe 'creating the xml' do
    before do
      Dir.stub(:pwd).and_return('/junit_path')
      File.stub(:open).and_call_original
      File.stub(:open).with('/junit_path/junit_results.xml', 'w').and_yield(file_stub)
    end

    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
        subject = Jasmine::Formatters::JunitXml.new

        subject.format(results)
        subject.done
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '0'
        testsuite['name'].should == 'Passing'

        xml.xpath('//testcase').size.should == 1
        xml.xpath('//testcase').first['name'].should == 'test'
      end
    end

    describe 'when there are failures' do
      it 'shows the spec counts' do
        results1 = [passing_result]
        results2 = [failing_result]
        subject = Jasmine::Formatters::JunitXml.new

        subject.format(results1)
        subject.format(results2)
        subject.done
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '0'

        testsuite = xml.xpath('/testsuites/testsuite')[1]
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '1'

        xml.xpath('//testcase').size.should == 2
        xml.xpath('//testcase/failure').size.should == 1
        xml.xpath('//testcase/failure').first['message'].should == 'a failure message'
        xml.xpath('//testcase/failure').first.content.should == 'a stack trace'
      end
    end
  end

  describe 'when the output directory has been customized' do
    before do
      Dir.stub(:pwd).and_return('/default_path')
      config_path = File.join('/default_path', 'spec', 'javascripts', 'support', 'jasmine_junitxml_formatter.yml')
      File.stub(:exist?).with(config_path).and_return(true)
      File.stub(:read).with(config_path).and_return <<-YAML
---
junit_xml_path: "/custom_path"
YAML
      File.stub(:open).and_call_original
      File.stub(:open).with('/custom_path/junit_results.xml', 'w').and_yield(file_stub)
    end

    it 'writes to the specified location' do
      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
      subject = Jasmine::Formatters::JunitXml.new

      subject.format(results)
      subject.done
      file_stub.content.should_not == ''
    end
  end

  def failing_result(options = {})
    Jasmine::Result.new(failing_raw_result.merge(options))
  end

  def passing_result(options = {})
    Jasmine::Result.new(passing_raw_result.merge(options))
  end
end
