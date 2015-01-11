require 'spec_helper'
require 'simple_email_exception_notifier/message'

RSpec.describe SimpleEmailExceptionNotifier::Message do
  describe '.compose' do
    it 'composes message from parts' do
      content = described_class.compose do |m|
        m.print_section('First', '_')
        m.print_section('Second', '_')
      end

      expect(content).to include('First')
      expect(content).to include('Second')
    end
  end

  describe '#print_summary' do
    it 'includes class name and message' do
      message = described_class.new
      message.print_summary(TestError.new('message'))
      content = message.to_s

      expect(content).to include('TestError')
      expect(content).to include('message')
    end
  end

  describe '#print_request' do
    let(:request) do
      instance_double('Rack::Request',
        url: 'http://example.com/missing',
        request_method: 'GET',
        ip: '238.214.27.14',
        params: {
          name: 'John Cage',
        }
      )
    end

    it 'includes request url' do
      content = described_class.new.print_request(request).to_s
      expect(content).to include(request.url)
    end

    it 'includes http method' do
      content = described_class.new.print_request(request).to_s
      expect(content).to include(request.request_method)
    end

    it 'includes ip address' do
      content = described_class.new.print_request(request).to_s
      expect(content).to include(request.params.fetch(:name))
    end
  end

  describe '#print_section' do
    it 'includes section' do
      message = described_class.new

      message.print_section('Backtrace', %w(some_file.rb:1 other_file.rb:2))
      content = message.to_s

      expect(content).to include('Backtrace')
      expect(content).to include('some_file.rb:1')
      expect(content).to include('other_file.rb:2')
    end
  end
end