# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Signer do
  let(:request) do
    {
      http_method: 'POST',
      url: 'https://example.com/posts',
      headers: {
        'User-Agent' => 'Test'
      },
      body: 'body'
    }
  end
  let(:signer) { described_class.new('access_key', 'secret_key', apply_checksum_header: true) }
  let(:signature) { signer.sign_request(request) }

  it 'must sign request' do
    expect(signature.headers['host']).to eq 'example.com'
    expect(signature.headers['x-content-sha256']).not_to eq nil
    expect(signature.headers['x-datetime']).not_to eq nil
    expect(signature.headers['authorization']).not_to eq nil
  end
end
