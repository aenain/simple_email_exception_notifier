require 'spec_helper'
require 'simple_email_exception_notifier/formatter'

RSpec.describe SimpleEmailExceptionNotifier::Formatter, '#text' do
  it 'converts argument to string' do
    formatted = described_class.new.text(3)

    expect(formatted).to eq '3'
  end
end

RSpec.describe SimpleEmailExceptionNotifier::Formatter, '#section' do
  it 'makes title stand out' do
    separator = /\n[-]+\n/

    formatted = described_class.new.section('title', 'details')

    expect(formatted).to match /\A#{separator}title:#{separator}/m
  end

  it 'makes details readable' do
    lots_of_data = {
      long_key: 3124124,
      longer_key: 412415,
      very_long_key: 525156111,
      super_long_key: 6124125111,
      extremely_long_key: 721415125125,
    }

    formatted = described_class.new.section('_', lots_of_data)

    expect(formatted).to match /:long_key => \d+,\n\s+:longer_key/m
  end
end