[![Build Status](https://semaphoreci.com/api/v1/igormalinovskiy/api_signature/branches/master/shields_badge.svg)](https://semaphoreci.com/igormalinovskiy/api_signature)
[![Code Climate](https://codeclimate.com/github/psyipm/api_signature/badges/gpa.svg)](https://codeclimate.com/github/psyipm/api_signature)
[![Gem Version](https://badge.fury.io/rb/api_signature.svg)](https://badge.fury.io/rb/api_signature)

# ApiSignature

Simple HMAC-SHA1 authentication via headers. Impressed by [AWS Requests with Signature Version 4](https://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html)

This gem will generate signature for the client requests and verify that signature on the server side

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_signature'
```

## Usage

The usage is pretty simple. To sign a request use ApiSignature::Signer and for validation use ApiSignature::Validator.

### Create signature

Sign a request with 'authorization' header. You can change header name, see Configuration section.

```ruby
api_access_key = 'access_key'
api_secret_key = 'secret_key'

request = {
  http_method: 'POST',
  url: 'https://example.com/posts',
  headers: {
    'User-Agent' => 'Test agent'
  },
  body: 'body'
}

# Sign your request
signature = ApiSignature::Signer.new(api_access_key, api_secret_key).sign_request(request)

# Now apply signed headers to your real request
signature.headers

# signature.headers looks like:
{
  "host"=>"example.com",
  "x-datetime"=>"2020-01-02T10:24:59.837+0000",
  "authorization"=>"API-HMAC-SHA256 Credential=access_key/20200102/web/api_request, SignedHeaders=host;user-agent;x-datetime, Signature=032fc0b7defd66d86ef43ced8e6c3ee351ede21deca6bf1f89b9145f7a9105c1"
}
```

### Validate signature

Validate the request on the client-side. Note, that access_key can be extracted from the request.

```ruby
# the request to validate
request = {
  :http_method=>"POST",
  :url=>"https://example.com/posts",
  :headers=>{
    "User-Agent"=>"Test agent",
    "host"=>"example.com",
    "x-datetime"=>"2020-01-02T10:24:59.837+0000",
    "authorization"=>"API-HMAC-SHA256 Credential=access_key/20200102/web/api_request, SignedHeaders=host;user-agent;x-datetime, Signature=032fc0b7defd66d86ef43ced8e6c3ee351ede21deca6bf1f89b9145f7a9105c1"
  },
  :body=>"body"
}

# initialize validator with a request to validate
validator = ApiSignature::Validator.new(request)

# get access key from request headers (String)
validator.access_key

# validate the request (Boolean)
validator.valid?('your secret key here')

# get only signed headers (Hash)
validator.signed_headers
```

## Configuration

By default, the generated signature will be valid for 5 minutes
This could be changed via initializer:

```ruby
# config/initializers/api_signature.rb

ApiSignature.setup do |config|
  # Time to live, by default 5 minutes
  config.signature_ttl = 5 * 60

  # Datetime format, by default iso8601
  config.datetime_format = '%Y-%m-%dT%H:%M:%S.%L%z'

  # Header name, by default authorization
  config.signature_header = 'authorization'

  # Service name, by default web
  config.service = 'web'
end
```

## Testing

In your `rails_helper.rb`:

```ruby
require 'api_signature/spec_support/helper'

RSpec.configure do |config|
  config.include ApiSignature::SpecSupport::Helper, type: :controller
end
```

This will enable the following methods in controller tests:

* get_with_signature(client, action_name, params = {})
* post_with_signature(client, action_name, params = {})
* put_with_signature(client, action_name, params = {})
* patch_with_signature(client, action_name, params = {})
* delete_with_signature(client, action_name, params = {})

`client` object should respond to `#api_key` and `#api_secret`

Example usage:

```ruby
RSpec.describe Api::V1::OrdersController do
  let(:client) { FactoryBot.create(:client) }
  # or any object, that responds to #api_key and #api_secret
  # let(:client) { OpenStruct.new(api_key: 'some_key', api_secret: 'some_api_secret') }

  it 'should filter orders by state' do
    get_with_signature client, :index, state: :paid

    expect(last_response.status).to eq 200
    expect(last_response.body).to have_node(:orders)
    expect(last_response.body).to have_node(:state).with('paid')
  end

  let(:order_attributes) { FactoryBot.attributes_for(:order) }

  it 'should create new order' do
    post_with_signature client, :create, order: order_attributes
  end
end
```

For nested resources path can be specified explicitly using `path` parameter:

```ruby
# path: /api/v1/orders/:order_id/comments

RSpec.describe Api::V1::CommentsController do
  let(:client) { OpenStruct.new(api_key: 'some_key', api_secret: 'some_api_secret') }
  let(:order) { FactoryBot.create(:order) }

  it 'should update comment for order' do
    put_with_signature client, :update, path: { order_id: order.id }, comment: { content: 'Some value' }
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_signature.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
