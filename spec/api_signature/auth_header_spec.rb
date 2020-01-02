# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::AuthHeader do
  let(:cred) { 'api_key/20191227/api_request' }
  let(:headers) { 'host;user-agent;x-content-sha256;x-datetime' }
  let(:sig) { 'xxx' }
  let(:data) do
    "API-HMAC-SHA256 Credential=#{cred}, SignedHeaders=#{headers}, Signature=#{sig}"
  end
  let(:header) { described_class.new(data) }

  it 'must parse credential' do
    expect(header.credential).to eq cred
  end

  it 'must parse signature' do
    expect(header.signature).to eq sig
  end

  it 'must parse headers' do
    expect(header.signed_headers).not_to eq nil
  end
end
