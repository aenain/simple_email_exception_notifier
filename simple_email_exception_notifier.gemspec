# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_email_exception_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_email_exception_notifier"
  spec.version       = SimpleEmailExceptionNotifier::VERSION
  spec.authors       = ["Artur Hebda"]
  spec.email         = ["arturhebda@gmail.com"]
  spec.summary       = %q{Email notifier for exception_notification that does not rely on ActionMailer and can be used with any Rack app.}
  spec.description   = %q{Plugin for exception_notification that can be used outside Rails, i.e. with Grape. As of now it supports only text emails. As a delivery method it can use either Mail or Pony or custom method you define.}
  spec.homepage      = "https://github.com/aenain/simple_email_exception_notifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rack", "~> 1.6"
  spec.add_development_dependency "mail", "~> 2.6"
  spec.add_development_dependency "pony", "~> 1.11"
  spec.add_development_dependency "exception_notification", "~> 4.0"
end
