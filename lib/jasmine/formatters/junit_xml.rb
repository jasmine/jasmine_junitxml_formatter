require 'nokogiri'

module Jasmine
  module Formatters
    class JunitXml
      def initialize
        load_config ENV['JASMINE_JUNIT_XML_CONFIG_PATH']
        @doc = Nokogiri::XML '<testsuites><testsuite name="Jasmine Suite"></testsuite></testsuites>', nil, 'UTF-8'
        @spec_count = 0
        @failure_count = 0
      end

      def format(results)
        testsuite = doc.at_css('testsuites testsuite')

        @spec_count += results.size

        results.each do |result|
          testcase = Nokogiri::XML::Node.new 'testcase', doc
          testcase['classname'] = result.suite_name
          testcase['name'] = result.description

          if result.failed?
            @failure_count += 1
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

      def done(run_details)
        testsuite = doc.at_css('testsuites testsuite')
        properties = Nokogiri::XML::Node.new 'properties', doc
        properties.parent = testsuite

        if run_details['order']
          random = Nokogiri::XML::Node.new 'property', doc
          random['name'] = 'random'
          random['value'] = run_details['order']['random']

          random.parent = properties

          if run_details['order']['random']
            seed = Nokogiri::XML::Node.new 'property', doc
            seed['name'] = 'seed'
            seed['value'] = run_details['order']['seed']

            seed.parent = properties
          end
        end

        testsuite['tests'] = @spec_count
        testsuite['failures'] = @failure_count
        testsuite['errors'] = 0

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
