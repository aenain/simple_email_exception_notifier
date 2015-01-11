require 'spec_helper'
require 'exception_notifier/simple_email_notifier'

RSpec.describe ExceptionNotifier::SimpleEmailNotifier, '#delivery_method' do
  let(:exception) { TestError.new }

  context 'when Mail defined' do
    it 'returns Mail.deliver' do
      hide_const('Pony')
      mail = class_double('Mail').as_stubbed_const
      allow(mail).to receive(:deliver)

      method = described_class.new({}).delivery_method

      expect(method).to eq Mail.method(:deliver)
    end
  end

  context 'when Pony defined' do
    it 'returns Pony.mail' do
      hide_const('Mail')
      pony = class_double('Pony').as_stubbed_const
      allow(pony).to receive(:mail)

      method = described_class.new({}).delivery_method

      expect(method).to eq Pony.method(:mail)
    end
  end

  context 'with custom :delivery_method' do
    it 'returns provided method' do
      delivery = double(:delivery, call: nil)

      method = described_class.new(delivery_method: delivery).delivery_method

      expect(method).to eq delivery
    end
  end

  context 'with no delivery method available' do
    it 'raises an error' do
      hide_const('Mail')
      hide_const('Pony')

      expect {
        described_class.new({}).delivery_method
      }.to raise_error(ExceptionNotifier::SimpleEmailNotifier::UndefinedDeliveryError)
    end
  end
end

RSpec.describe ExceptionNotifier::SimpleEmailNotifier, '#call' do
  describe 'subject' do
    let(:exception) { TestError.new }

    context 'with custom :email_prefix' do
      it 'consists of :email_prefix and exception class name' do
        delivery = double(:delivery, call: nil)

        described_class.new(
          email_prefix: 'ERROR ',
          delivery_method: delivery
        ).call(exception)

        expect(delivery).to have_received(:call)
          .with(hash_including(subject: 'ERROR TestError'))
      end
    end

    context 'with :env' do
      it 'contains request path' do
        delivery = double(:delivery, call: nil)
        env = Rack::MockRequest.env_for('/missing')

        described_class.new(
          delivery_method: delivery
        ).call(exception, env: env)

        expect(delivery).to have_received(:call)
          .with(hash_including(subject: '[ERROR] /missing TestError'))
      end
    end
  end

  describe 'sender' do
    let(:exception) { TestError.new }

    context 'with custom :sender_address' do
      it 'uses the address as :from' do
        delivery = double(:delivery, call: nil)

        described_class.new(
          sender_address: 'no-reply@example.com',
          delivery_method: delivery
        ).call(exception)

        expect(delivery).to have_received(:call)
          .with(hash_including(from: 'no-reply@example.com'))
      end
    end
  end

  describe 'recipients' do
    let(:exception) { TestError.new }

    context 'with custom :exception_recipients' do
      it 'uses list of addresses as :to' do
        delivery = double(:delivery, call: nil)

        described_class.new(
          exception_recipients: %w(developers@example.com),
          delivery_method: delivery
        ).call(exception)

        expect(delivery).to have_received(:call)
          .with(hash_including(to: %w(developers@example.com)))
      end
    end
  end

  describe 'message' do
    it 'includes backtrace' do
      delivery = ->(args) { @passed_body = args.fetch(:body) }
      exception = instance_double('TestError',
        message: nil,
        backtrace: %w(some_file.rb:1 other_file.rb:2)
      )

      described_class.new(delivery_method: delivery).call(exception)

      expect(@passed_body).to include exception.backtrace[0]
    end

    it 'includes exception message' do
      delivery = ->(args) { @passed_body = args.fetch(:body) }
      exception = instance_double('TestError',
        message: 'Some helpful message',
        backtrace: []
      )

      described_class.new(delivery_method: delivery).call(exception)

      expect(@passed_body).to include exception.message
    end

    it 'includes :env' do
      delivery = ->(args) { @passed_body = args.fetch(:body) }
      env = Rack::MockRequest.env_for('/missing')

      described_class.new(delivery_method: delivery)
        .call(TestError.new, env: env)

      expect(@passed_body).to match /PATH_INFO.*\/missing/
    end
  end
end

RSpec.describe ExceptionNotifier::SimpleEmailNotifier, 'naming requirements' do
  it 'is defined directly in ExceptionNotifier' do
    namespaces = described_class.name.split('::')

    expect(namespaces.count).to eq 2
    expect(namespaces[0]).to eq 'ExceptionNotifier'
  end

  it 'has suffix of Notifier' do
    expect(described_class.name).to match /Notifier$/
  end
end

RSpec.describe ExceptionNotifier::SimpleEmailNotifier, 'interface' do
  describe 'constructor' do
    it 'has one argument' do
      method = described_class.instance_method(:initialize)
      expect(method.arity).to eq 1
    end
  end

  describe '#call' do
    it 'has one required and one optional argument' do
      method = described_class.instance_method(:call)
      expect(method.arity).to eq -2
    end
  end
end