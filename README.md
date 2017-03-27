# Sparkpost-Rails5

Simple ActionMailer provider for sending mail through Sparkpost API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sparkpost_rails5', require: "sparkpost_rails"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sparkpost_rails5

## Usage

Add this to corresponding environment configuration file (`config/environments/*.rb`):
```ruby
config.action_mailer.delivery_method = :sparkpost_rails
```

And make sure `ENV['SPARKPOST_API_KEY']` is set.

You can also provide custom options through `sparkpost_payload` method. The value will be merged with request payload:
```ruby
class UserMailer < ApplicationMailer

  def confirmation_email(email)
    sparkpost_payload(
      options: {
        open_tracking: true
      },
      campaign_id: "Your campaign ID"
      description: "Confirmation email",
      content: {
        headers: {
          "X-Custom-Header" => "custom header value"
        }
      }
    )
    mail(to: email, subject: "Confirm Your Account!!!")
  end

end
```
See [https://developers.sparkpost.com/api/transmissions.html#transmissions-create](https://developers.sparkpost.com/api/transmissions.html#transmissions-create)

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/muhlisbc/sparkpost_rails5. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
