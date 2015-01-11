require 'exception_notifier_simple_email/message'

module ExceptionNotifier
  class SimpleEmailNotifier
    class UndefinedDeliveryError < StandardError; end

    ENV_DATA_KEY = 'exception_notifier.exception_data'.freeze

    def self.default_options
      {
        :sender_address => %("Exception Notifier" <exception.notifier@example.com>),
        :exception_recipients => [],
        :email_prefix => "[ERROR] ",
      }
    end

    def initialize(options)
      @options = self.class.default_options.merge(options)
    end

    def call(exception, options = {})
      env = extract_env_from_options!(options)

      delivery_method.call(
        from: @options.fetch(:sender_address),
        to: @options.fetch(:exception_recipients),
        subject: compose_subject(exception, env, options),
        body: compose_message(exception, env, options)
      )
    end

    def delivery_method
      @options.fetch(:delivery_method) do
        if defined?(Mail)
          Mail.method(:deliver)
        elsif defined?(Pony)
          Pony.method(:mail)
        else
          raise UndefinedDeliveryError.new "Undefined :delivery_method!\n" +
            " You can add gem 'mail' or 'pony' to Gemfile or provide custom method.\n" +
            " It is supposed to send message on #call.\n" +
            " Arguments are :from, :to, :subject and :body.\n" +
            " Examples: Mail.method(:deliver), Pony.method(:mail)"
        end
      end
    end

    def compose_subject(exception, env, options)
      [
        @options.fetch(:email_prefix),
        env['PATH_INFO'].to_s + ' ',
        exception.class.name,
      ].join.squeeze(' ')
    end

    def compose_message(exception, env, options)
      ExceptionNotifierSimpleEmail::Message.compose do |m|
        m.print_summary(exception)
        m.print_section('Backtrace', exception.backtrace)

        unless env.empty?
          m.print_request(Rack::Request.new(env)) if defined?(Rack::Request)
          m.print_section('Environment', filter_env(env))
        end

        m.print_section('Data', extract_data(env, options))
      end
    end

    private

    def extract_env_from_options!(options)
      options.delete(:env) || {}
    end

    def filter_env(env)
      env.reject { |k, _| k == ENV_DATA_KEY }
    end

    def extract_data(env, options)
      env_data = env.fetch(ENV_DATA_KEY, {})
      env_data.merge(options.fetch(:data, {}))
    end
  end
end