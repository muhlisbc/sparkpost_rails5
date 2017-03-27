# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sparkpost_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "sparkpost_rails5"
  spec.version       = SparkpostRails::VERSION
  spec.authors       = ["Muhlis BC"]
  spec.email         = ["muhlisbc@gmail.com"]

  spec.summary       = "ActionMailer provider for sending mail through Sparkpost API."
  spec.description   = "Send mail through Sparkpost API from Rails 5 app."
  spec.homepage      = "https://github.com/muhlisbc/sparkpost_rails5"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin)/})
  end
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "rails", "~> 5.0"
  spec.add_dependency "simple_spark", "~> 1.0.0"
end
