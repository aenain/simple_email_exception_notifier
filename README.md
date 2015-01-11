# SimpleEmailExceptionNotifier

[![Gem Version](https://badge.fury.io/rb/simple_email_exception_notifier.svg)](http://badge.fury.io/rb/simple_email_exception_notifier)
[![Dependency Status](https://gemnasium.com/aenain/simple_email_exception_notifier.svg)](https://gemnasium.com/aenain/simple_email_exception_notifier)
[![Build Status](https://travis-ci.org/aenain/simple_email_exception_notifier.svg?branch=master)](https://travis-ci.org/aenain/simple_email_exception_notifier)
[![Code Climate](https://codeclimate.com/github/aenain/simple_email_exception_notifier/badges/gpa.svg)](https://codeclimate.com/github/aenain/simple_email_exception_notifier)

Email notifier for [exception_notification](https://github.com/smartinez87/exception_notification) that does not rely on ActionMailer and can be used outside Rails, i.e. with Grape. As of now it supports only text emails. As a delivery method it can use either [Mail](https://github.com/mikel/mail) or [Pony](https://github.com/benprew/pony) or custom method you define.

## Why?

I have created a few apps using Rails in conjuction with Exception Notification and I liked it. Then I have started a new app which consists of API and backend processing only. It's based on [Grape](https://github.com/intridea/grape) and [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord). Once I have added `require 'exception_notifier/email_notifier'` to configure it app stopped to boot, because this file requires ActionMailer, which in turn does `require 'active_support/rails'`. That makes ActiveRecord start thinking that there is a Rails app and raises `NoMethodError: undefined method 'env' for Rails:Module`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_email_exception_notifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_email_exception_notifier

## Usage

### Migrating from Rails

In Rails with built-in email notifier you would do like this:

```ruby
# config/initializers/smtp.rb
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
    # See: http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
}
```

```ruby
# config/initializers/exception_notification.rb
require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  config.ignore_if do |exception, options|
    Rails.env.development? || Rails.env.test?
  end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    :email_prefix         => "[ERROR] ",
    :sender_address       => "no-reply@example.com",
    :exception_recipients => %w[artur@boostcommedia.no]
  }
end
```

Let's think about the config above as a reference point to highlight what is different in Rack app. Check out the config below.

### Rack app

I tend to keep structure of the directories similar to what Rails offers, therefore I'll keep the same filenames as in the Rails config above. For Grape and Sinatra it means that those files have to required manually.

In Rack app with this notifier you would do similar to this:

```ruby
# Gemfile
gem 'simple_email_exception_notifier'
gem 'mail'
```

```ruby
# config/initializers/smtp.rb
require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    # See: http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
  }
end
```

```ruby
# config/initializers/exception_notification.rb
require 'exception_notification/rack'
require 'simple_email_exception_notifier'

ExceptionNotification.configure do |config|
  config.ignore_if do |exception, options|
    env = ENV['RACK_ENV'] || 'development'
    %w(development test).include?(env)
  end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :simple_email, {
    :email_prefix         => "[ERROR] ",
    :sender_address       => "no-reply@example.com",
    :exception_recipients => %w[artur@boostcommedia.no]
  }
end
```

### Include ExceptionNotification in Rack stack

Let's say that what you usually do is to run a Rack app with `run App`.
In such case you would do as follows:

```ruby
run Rack::Builder.new do
  use ExceptionNotification::Rack
  run App # your app
end
```

### Pony instead of Mail

If you would like to use Pony instead of Mail, it's as simple as:

```ruby
# Gemfile
gem 'simple_email_exception_notifier'
gem 'pony'
```

```ruby
# config/initializers/smtp.rb
require 'pony'

Pony.options = {
    :via => :smtp,
    :via_options => {
        # See: https://github.com/benprew/pony
        # As far as I have tested options are identical to those for Mail
    }
}
```

### Custom delivery method

You can customize delivery method if you like. If not defined, at the moment of notifying the lookup is as follows: Mail, Pony, raising error.

```ruby
# config/initializers/exception_notification.rb
config.add_notifier :simple_email, {
    :email_prefix         => "[ERROR] ",
    :sender_address       => "no-reply@example.com",
    :exception_recipients => %w[artur@boostcommedia.no],
    :delivery_method      => ->(params) {
        # do something with :from, :to, :subject and :body.
    }
}
```

## Contributing

1. Fork it ( https://github.com/aenain/simple_email_exception_notifier/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
