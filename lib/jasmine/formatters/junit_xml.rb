require 'nokogiri'

module Jasmine
  module Formatters
    class JunitXml
      def initialize
        load_config ENV['JASMINE_JUNIT_XML_CONFIG_PATH']
        @doc = Nokogiri::XML '<testsuites></testsuites>', nil, 'UTF-8'
      end

      def format(results)
        testsuites = doc.at_css('testsuites')

        results.each do |result|
          testsuite = Nokogiri::XML::Node.new 'testsuite', doc
          testsuite['tests'] = 1
          testsuite['failures'] = result.failed? ? 1 : 0
          testsuite['errors'] = 0
          testsuite['name'] = result.suite_name
          testsuite.parent = testsuites

          testcase = Nokogiri::XML::Node.new 'testcase', doc
          testcase['name'] = result.description

          if result.failed?
            result.failed_expectations.each do |failed_exp|
              failure = Nokogiri::XML::Node.new 'failure', doc
              failure['message'] = failed_exp.message
              failure['type'] = 'Failure'
              failure.content = failed_exp.stack
              failure.parent = testcase
            end
          end

          testcase.parent = testsuite
        end
      end

      def done
        FileUtils.mkdir_p(output_dir)
        File.open(File.join(output_dir, 'junit_results.xml'), 'w') do |file|
          file.puts doc.to_xml(indent: 2)
        end
      end

      private
      attr_reader :doc, :config

      def output_dir
        config['junit_xml_path'] || Dir.pwd
      end

      def load_config(filepath=nil)
        filepath ||= File.join(Dir.pwd, 'spec', 'javascripts', 'support', 'jasmine_junitxml_formatter.yml')
        @config = YAML::load(ERB.new(File.read(filepath)).result(binding)) if File.exist?(filepath)
        @config ||= {}
      end
    end
  end
end
