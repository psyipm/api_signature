[![Build Status](https://semaphoreci.com/api/v1/igormalinovskiy/api_signature/branches/master/shields_badge.svg)](https://semaphoreci.com/igormalinovskiy/api_signature)
[![Code Climate](https://codeclimate.com/github/psyipm/api_signature/badges/gpa.svg)](https://codeclimate.com/github/psyipm/api_signature)
[![Gem Version](https://badge.fury.io/rb/api_signature.svg)](https://badge.fury.io/rb/api_signature)

# ApiSignature

Simple HMAC-SHA1 authentication via headers

This gem will generate signature for the client requests and verify that signature on the server side

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_signature'
```

And then execute:

    $ bundle

## Usage

### Server side

Implement warden strategy:
```ruby
module MyApplication
  module API
    class ClientAuthenticatable < Warden::Strategies::Base
      delegate :valid?, to: :api_request

      def authenticate!
        # Find client in database by public api_key
        resource = Client.find_for_token_authentication(api_request.access_key)
        return fail!(:not_found_in_database) unless resource

        # Check request signature
        return unless api_request.correct?(resource.api_key, resource.api_secret)

        # Perform some after_authentication callbacks
        resource.after_authentication

        # Tell warden that authentication was successful
        success!(resource)
      end

      private

      def api_request
        @api_request ||= ::ApiSignature::Request.new(env)
      end
    end
  end
end
```

```ruby
module MyApplication
  module API
    module Authentication
      extend ActiveSupport::Concern

      protected

      def warden
        @warden ||= request.env['warden']
      end

      def current_client
        @current_client ||= warden.user(:client)
      end

      def authenticate_client!
        warden.authenticate!(:client_authenticatable, scope: :client)
      end
    end
  end
end
```

```ruby
class Api::BaseController < ActionController::API do
  abstract!

  include MyApplication::API::Authentication

  before_action :authenticate_client!
end
```

### On client side:

```ruby
options = {
  request_method: 'GET',
  path: '/api/v1/some_path'
  access_key: 'client public api_key',
  timestamp: Time.zone.now.to_i
}

signature = ApiSignature::Generator.new(options).generate_signatute('api_secret')
```

By default, the generated signature will be valid for 2 hours
This could be changed via initializer:

```ruby
# config/initializers/api_signature.rb

ApiSignature.setup do |config|
  config.signature_ttl = 1.minute
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_signature.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
