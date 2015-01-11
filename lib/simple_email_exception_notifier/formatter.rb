require 'pp'

module SimpleEmailExceptionNotifier
  class Formatter
    def text(text)
      text.to_s
    end

    def section(title, details)
      [
        nil,
        '-------------------------------',
        "#{title}:",
        '-------------------------------',
        nil,
        pretty_inspect(details),
      ].join("\n")
    end

    private

    def pretty_inspect(object)
      out = StringIO.new
      PP.pp(object, out)
      out.rewind
      out.read.gsub(/(=[>]*)/m, ' \1 ')
    end
  end
end