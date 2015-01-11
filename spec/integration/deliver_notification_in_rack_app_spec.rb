require 'spec_helper'

require 'rack/test'
require 'rack/builder'
require 'exception_notifier'
require 'exception_notification/rack'

RSpec.describe 'error in rack app' do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use ExceptionNotification::Rack,
        simple_email: {
          sender_address: 'notifier@example.com',
          exception_recipients: %w(developers@example.com),
        }
      run ->(env) { raise TestError.new('Test message') }
    end
  end

  describe 'delivered email' do
    context 'with mail' do
      include Mail::Matchers

      before(:each) do
        Mail::TestMailer.deliveries.clear
        get '/missing' rescue TestError
      end

      it { should have_sent_email.from('notifier@example.com') }
      it { should have_sent_email.to('developers@example.com') }
      it { should have_sent_email.matching_subject(/TestError/) }
      it { should have_sent_email.matching_body(/PATH_INFO.*\/missing/) }
    end
  end
end