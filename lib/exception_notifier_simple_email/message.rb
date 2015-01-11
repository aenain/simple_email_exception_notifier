require_relative 'formatter'

module ExceptionNotifierSimpleEmail
  class Message
    def initialize(formatter = Formatter.new)
      @content = []
      @formatter = formatter
    end

    def self.compose(formatter = Formatter.new, &block)
      message = self.new(formatter)
      block.call(message)
      message.to_s
    end

    def print_summary(exception)
      opening_line = "#{exception.class} occurred at #{Time.now.utc} :"
      content << formatter.text(opening_line)
      content << formatter.text(exception.message)
    end

    def print_request(request)
      print_section('Request',
        url: request.url,
        http_method: request.request_method,
        ip_address: request.ip,
        parameters: request.params,
        server: Socket.gethostname
      )
    end

    def print_section(title, details)
      content << formatter.section(title, details)
    end

    def to_s
      content.flatten.join("\n")
    end

    private

    attr_reader :content, :formatter
  end
end