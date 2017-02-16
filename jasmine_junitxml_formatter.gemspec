# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jasmine_junitxml_formatter/version'

def ruby_version_less_than(target_version)
  version_parts = RUBY_VERSION.split('.').map(&:to_i).zip(target_version)

  version_parts.each do |(current_part, target_part)|
    if current_part < target_part
      return true
    end
  end
  false
end

Gem::Specification.new do |spec|
  spec.name          = "jasmine_junitxml_formatter"
  spec.version       = JasmineJunitxmlFormatter::VERSION
  spec.authors       = ["Gregg Van Hove"]
  spec.email         = ["gvanhove@pivotal.io"]
  spec.description   = %q{Format jasmine results as junit compatible XML so CI servers, like Hudson/Jenkins can parse it}
  spec.summary       = %q{Format jasmine results as junit compatible XML so CI servers, like Hudson/Jenkins can parse it}
  spec.homepage      = "https://github.com/jasmine/jasmine_junitxml_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "rake"

  spec.add_dependency 'jasmine', '~> 2.4'
  if ruby_version_less_than([2,1,0])
    spec.add_dependency 'nokogiri', '< 1.7.0'
  else
    spec.add_dependency 'nokogiri'
  end
end
