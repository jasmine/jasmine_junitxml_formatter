# Jasmine JUnit Xml Formatter

Format jasmine results as junit compatible XML so CI servers, like Hudson/Jenkins can parse it

## Installation

Add this line to your application's Gemfile:

    gem 'jasmine_junitxml_formatter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jasmine_junitxml_formatter

## Usage

Now when you run `rake jasmine:ci` a JUnit compatible XML file will be written

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
