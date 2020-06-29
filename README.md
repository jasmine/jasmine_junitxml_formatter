# Jasmine JUnit Xml Formatter [![Build Status](https://travis-ci.org/jasmine/jasmine_junitxml_formatter.png?branch=main)](https://travis-ci.org/jasmine/jasmine_junitxml_formatter)

Format jasmine results as junit compatible XML so CI servers, like Hudson/Jenkins can parse it

## Installation

Add this line to your application's Gemfile:

    gem 'jasmine_junitxml_formatter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jasmine_junitxml_formatter

## Usage

- In rails, simply `run rake jasmine:ci`, tests should generate a JUnit XML file
- Outside of rails, you may need to add `require 'jasmine_junitxml_formatter'` to your Rakefile after jasmine is required.

### Configuring the output location:

Create a jasmine_junitxml_formatter.yml in spec/javascripts/support with something like this:

    ---
    junit_xml_path: /absolute/path/to/output

The config file will be processed with ERB if you want to make the destination dynamic. e.g.

    ---
    junit_xml_path: <%= File.join(Dir.pwd, 'some', 'relative', 'path')

### Configuring the output filename:

To configure the filename of the XML file that is generated, the `junit_xml_filename` configuration option can be used, otherwise the default filename is `junit_results.xml`

    ---
    junit_xml_filename: custom_filename.junit.xml

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
