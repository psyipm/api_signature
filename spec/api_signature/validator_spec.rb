# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Validator do
  let(:user_agent) { 'Googlebot/2.1 (+http://www.google.com/bot.html)' }
  let(:body) { 'body' }
  let(:request_to_sign) do
    {
      http_method: 'POST',
      url: 'https://example.com/posts',
      headers: {
        'User-Agent' => user_agent
      },
      body: body
    }
  end
  let(:request_to_validate) do
    data = request_to_sign[:headers].merge(signature.headers)
    request_to_sign.merge(headers: data)
  end
  let(:secret_key) { 'secret_key' }
  let(:access_key) { 'access_key' }
  let(:signer) { ApiSignature::Signer.new(access_key, secret_key, apply_checksum_header: true) }
  let(:signature) { signer.sign_request(request_to_sign) }
  let(:validator) { described_class.new(request_to_validate) }

  it 'must validate request' do
    expect(validator.access_key).to eq access_key
    expect(validator.valid?(secret_key)).to eq true
  end

  it 'must be wrong request with invalid secret keys' do
    expect(validator.valid?('wrong')).to eq false
    expect(validator.valid?(nil)).to eq false
    expect(validator.valid?(Time.now.to_i)).to eq false
  end

  it 'must return signed_headers only' do
    expect(validator.signed_headers.size).to eq 4

    expect(validator.signed_headers['host']).to eq 'example.com'
    expect(validator.signed_headers['user-agent']).to eq user_agent
    expect(validator.signed_headers['x-content-sha256']).to eq ApiSignature::Utils.sha256_hexdigest(body)
    expect(validator.signed_headers['x-datetime']).not_to eq nil
  end

  context 'when expired datetime' do
    let(:ttl) { ApiSignature.configuration.signature_ttl + 1 }

    let(:request_to_sign) do
      {
        http_method: 'POST',
        url: 'https://example.com/posts',
        headers: {
          'User-Agent' => user_agent,
          'x-datetime' => (Time.now - ttl).strftime(ApiSignature.configuration.datetime_format)
        },
        body: body
      }
    end

    it 'must not be valid timestamp' do
      expect(validator.valid_timestamp?).to eq false
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when authorization blank' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers)
      data.delete(ApiSignature.configuration.signature_header)

      request_to_sign.merge(headers: data)
    end

    it 'must not be valid request' do
      expect(validator.valid_authorization?).to eq false
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when different secret key' do
    it 'must not be valid signature' do
      expect(validator.valid_signature?('something other')).to eq false
      expect(validator.valid?('something other')).to eq false
    end
  end

  context 'when different http_method' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers)
      request_to_sign.merge(headers: data, http_method: 'GET')
    end

    it 'must not be valid request' do
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when different url' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers)
      request_to_sign.merge(headers: data, url: 'https://example.com/posts/test')
    end

    it 'must not be valid request' do
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when different header: user-agent' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers).merge('User-Agent' => 'test')
      request_to_sign.merge(headers: data)
    end

    it 'must not be valid request' do
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when other unsigned header' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers).merge('Content-Type' => 'application/json')
      request_to_sign.merge(headers: data)
    end

    it 'must not be valid request' do
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when different body' do
    let(:request_to_validate) do
      data = request_to_sign[:headers].merge(signature.headers)
      request_to_sign.merge(headers: data, body: 'test')
    end

    it 'must not be valid request' do
      expect(validator.valid?(secret_key)).to eq false
    end
  end

  context 'when empty authorization header' do
    let(:request_to_validate) do
      request_to_sign
    end

    it 'must return blank access_key' do
      expect(validator.access_key).to eq nil
    end

    it 'must return blank signed headers' do
      expect(validator.signed_headers).to eq({})
    end
  end
end
