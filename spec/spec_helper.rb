ENV['RACK_ENV'] = 'test'

require 'rack/mock'
require 'mail'
require 'pony'

class TestError < RuntimeError; end

Mail.defaults do
  delivery_method :test
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end