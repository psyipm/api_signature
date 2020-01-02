# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature do
  it 'has a version number' do
    expect(ApiSignature::VERSION).not_to be nil
  end

  context 'readme' do
    let(:api_access_key) { 'access_key' }
    let(:api_secret_key) { 'secret_key' }
    let(:request) do
      {
        http_method: 'POST',
        url: 'https://example.com/posts',
        headers: {
          'User-Agent' => 'Test agent'
        },
        body: 'body'
      }
    end
    let(:signer) { ApiSignature::Signer.new(api_access_key, api_secret_key) }
    let(:signature) { signer.sign_request(request) }

    it 'must create signature' do
      expect(signature.headers).not_to eq nil
    end

    it 'must validate signature' do
      request[:headers].merge!(signature.headers)

      validator = ApiSignature::Validator.new(request)
      # get key from request headers
      expect(validator.access_key).to eq api_access_key

      expect(validator.valid?(api_secret_key)).to eq true
      expect(validator.valid?('wrong')).to eq false
    end
  end
end
