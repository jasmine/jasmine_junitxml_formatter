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

  before do
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe 'creating the xml' do
    before do
      allow(Dir).to receive(:pwd).and_return('/junit_path')
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/junit_path/junit_results.xml', 'w').and_yield(file_stub)
    end

    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
        subject = Jasmine::Formatters::JunitXml.new

        subject.format(results)
        subject.done({})
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        expect(testsuite['tests']).to eq '1'
        expect(testsuite['failures']).to eq '0'
        expect(testsuite['name']).to eq 'Jasmine Suite'

        expect(xml.xpath('//testcase').size).to eq 1
        expect(xml.xpath('//testcase').first['classname']).to eq 'Passing'
        expect(xml.xpath('//testcase').first['name']).to eq 'test'
      end
    end

    describe 'when there are pending specs' do
      it "shows the spec counts" do
        results = [pending_result('fullName' => 'Pending test', 'description' => 'test')]
        subject = Jasmine::Formatters::JunitXml.new

        subject.format(results)
        subject.done({})
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        expect(testsuite['tests']).to eq '1'
        expect(testsuite['failures']).to eq '0'
        expect(testsuite['name']).to eq 'Jasmine Suite'

        expect(xml.xpath('//testcase').size).to eq 1
        expect(xml.xpath('//testcase').first['classname']).to eq 'Pending'
        expect(xml.xpath('//testcase').first['name']).to eq 'test'
        expect(xml.xpath('//testcase/skipped').first).to_not eq(nil)
      end
    end

    describe 'when there are failures' do
      it 'shows the spec counts' do
        results1 = [passing_result]
        results2 = [failing_result]
        subject = Jasmine::Formatters::JunitXml.new

        subject.format(results1)
        subject.format(results2)
        subject.done({})
        xml = Nokogiri::XML(file_stub.content)

        expect(xml.xpath('/testsuites/testsuite').size).to eq(1)
        testsuite = xml.xpath('/testsuites/testsuite').first
        expect(testsuite['tests']).to eq '2'
        expect(testsuite['failures']).to eq '1'

        expect(xml.xpath('//testcase').size).to eq 2
        expect(xml.xpath('//testcase/failure').size).to eq 1
        expect(xml.xpath('//testcase/failure').first['message']).to eq 'a failure message'
        expect(xml.xpath('//testcase/failure').first.content).to eq 'a stack trace'
      end
    end

    describe 'when there are failures in jasmineDone from a global afterAll' do
      it 'adds a failing testcase node' do
        subject = Jasmine::Formatters::JunitXml.new

        subject.done({ 'failedExpectations' => [{ 'message' => 'Failure Message', 'stack' => 'failure stack' }] })
        xml = Nokogiri::XML(file_stub.content)

        expect(xml.xpath('/testsuites/testsuite').size).to eq(1)
        testsuite = xml.xpath('/testsuites/testsuite').first
        expect(testsuite['tests']).to eq '0'
        expect(testsuite['failures']).to eq '1'

        expect(xml.xpath('//testcase').size).to eq 1
        expect(xml.xpath('//testcase/failure').size).to eq 1
        expect(xml.xpath('//testcase/failure').first['message']).to eq 'Failure Message'
        expect(xml.xpath('//testcase/failure').first.content).to eq 'failure stack'
      end
    end

    describe 'with randomization information' do
      it 'includes randomization seed when randomized' do
        subject.format([])
        subject.done({'order' => {'random' => true, 'seed' => '4321'}})
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        properties = testsuite.xpath('properties')

        expect(properties.xpath("property[@name='random']").first['value']).to eq('true')
        expect(properties.xpath("property[@name='seed']").first['value']).to eq('4321')
      end

      it 'does not include a seed when not randomized' do
        subject.format([])
        subject.done({'order' => {'random' => false}})
        xml = Nokogiri::XML(file_stub.content)

        testsuite = xml.xpath('/testsuites/testsuite').first
        properties = testsuite.xpath('properties')

        expect(properties.xpath("property[@name='random']").first['value']).to eq('false')
        expect(properties.xpath("property[@name='seed']").size).to eq(0)
      end
    end
  end

  describe 'when the output directory has been customized' do
    before do
      allow(Dir).to receive(:pwd).and_return('/default_path')
      config_path = File.join('/default_path', 'spec', 'javascripts', 'support', 'jasmine_junitxml_formatter.yml')
      allow(File).to receive(:exist?).with(config_path).and_return(true)
      allow(File).to receive(:read).with(config_path).and_return <<-YAML
---
junit_xml_path: "/custom_path"
YAML
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/custom_path/junit_results.xml', 'w').and_yield(file_stub)
    end

    it 'writes to the specified location' do
      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
      subject = Jasmine::Formatters::JunitXml.new

      subject.format(results)
      subject.done({})
      expect(file_stub.content).to_not eq ''
    end

    it 'creates the directory if it does not exist' do
      subject = Jasmine::Formatters::JunitXml.new

      subject.format([])
      expect(FileUtils).to receive(:mkdir_p).with('/custom_path')
      subject.done({})
    end
  end

  describe 'when the output filename has been customized' do
    before do
      allow(Dir).to receive(:pwd).and_return('/default_path')
    end

    it 'writes to the specified location if provided in jasmine_junitxml_formatter.yml' do
      config_path = File.join('/default_path', 'spec', 'javascripts', 'support', 'jasmine_junitxml_formatter.yml')
      allow(File).to receive(:exist?).with(config_path).and_return(true)
      allow(File).to receive(:read).with(config_path).and_return <<-YAML
---
junit_xml_filename: "custom_filename.junit.xml"
YAML
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/default_path/custom_filename.junit.xml', 'w').and_yield(file_stub)

      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
      subject = Jasmine::Formatters::JunitXml.new

      subject.format(results)
      subject.done({})
      expect(file_stub.content).to_not eq ''
    end

    it 'writes to default location if junit_xml_filename is not provided in jasmine_junitxml_formatter.yml' do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/default_path/junit_results.xml', 'w').and_yield(file_stub)

      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
      subject = Jasmine::Formatters::JunitXml.new

      subject.format(results)
      subject.done({})
      expect(file_stub.content).to_not eq ''
    end
  end

  describe 'when both the output directory and output filename has been customized' do
    it 'writes to the customized location using the customized filename if provided in jasmine_junitxml_formatter.yml' do
      allow(Dir).to receive(:pwd).and_return('/default_path')
      config_path = File.join('/default_path', 'spec', 'javascripts', 'support', 'jasmine_junitxml_formatter.yml')
      allow(File).to receive(:exist?).with(config_path).and_return(true)
      allow(File).to receive(:read).with(config_path).and_return <<-YAML
---
junit_xml_path: "/custom_path"
junit_xml_filename: "custom_filename.junit.xml"
YAML
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/custom_path/custom_filename.junit.xml', 'w').and_yield(file_stub)

      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
      subject = Jasmine::Formatters::JunitXml.new

      subject.format(results)
      subject.done({})
      expect(file_stub.content).to_not eq ''
    end
  end

  describe 'with a custom config file path' do
    before do
      allow(Dir).to receive(:pwd).and_return('/default_path')
      config_path = File.join('/other_path', 'jasmine_junitxml_formatter.yml')
      allow(File).to receive(:exist?).with(config_path).and_return(true)
      allow(File).to receive(:read).with(config_path).and_return <<-YAML
---
junit_xml_path: "/other_custom_path"
YAML
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/other_custom_path/junit_results.xml', 'w').and_yield(file_stub)
    end

    subject do
      ENV['JASMINE_JUNIT_XML_CONFIG_PATH'] = '/other_path/jasmine_junitxml_formatter.yml'
      formatter = Jasmine::Formatters::JunitXml.new
      ENV.delete 'JASMINE_JUNIT_XML_CONFIG_PATH'
      formatter
    end

    it 'writes to the specified location' do
      results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]

      subject.format(results)
      subject.done({})
      expect(file_stub.content).to_not eq ''
    end

    it 'creates the directory if it does not exist' do
      subject.format([])
      expect(FileUtils).to receive(:mkdir_p).with('/other_custom_path')
      subject.done({})
    end
  end

  def failing_result(options = {})
    Jasmine::Result.new(failing_raw_result.merge(options))
  end

  def passing_result(options = {})
    Jasmine::Result.new(passing_raw_result.merge(options))
  end

  def pending_result(options = {})
    Jasmine::Result.new(pending_raw_result.merge(options))
  end
end
