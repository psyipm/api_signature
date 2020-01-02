# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Builder do
  let(:env) do
    {
      http_method: 'put',
      url: 'https://domain.com/test',
      headers: {
        'User-Aget' => 'test',
        'Content-Type' => 'application/json'
      },
      body: 'body'
    }
  end
  let(:builder) { described_class.new(env) }

  it 'must extract http_method' do
    expect(builder.http_method).to eq 'PUT'
  end

  it 'must extract uri' do
    expect(builder.uri.path).to eq '/test'
  end

  it 'must extract host' do
    expect(builder.host).to eq 'domain.com'
  end

  it 'must extract headers' do
    expect(builder.headers['user-aget']).to eq 'test'
    expect(builder.headers['content-type']).to eq 'application/json'
  end

  it 'must extract datetime' do
    expect(builder.datetime).not_to eq nil
  end

  it 'must extract date' do
    expect(builder.date).not_to eq nil
  end

  it 'must extract content_sha256' do
    expect(builder.content_sha256).not_to eq nil
  end

  it 'must extract body' do
    expect(builder.body).not_to eq nil
  end

  it 'must build sign headers' do
    expect(builder.build_sign_headers['host']).to eq 'domain.com'
  end

  it 'must not build full headers without build_sign_headers' do
    expect { builder.full_headers }.to raise_error(ArgumentError)
  end

  context 'sign_headers' do
    before(:each) do
      builder.build_sign_headers(true)
    end

    it 'must build full headers' do
      expect(builder.full_headers['host']).to eq 'domain.com'
      expect(builder.full_headers['user-aget']).to eq 'test'
    end

    it 'must build signed_headers_names' do
      expect(builder.signed_headers_names).to eq 'content-type;host;user-aget;x-content-sha256;x-datetime'
    end

    it 'must build canonical_request' do
      expect(builder.canonical_request('/method_name')).not_to eq nil
    end
  end
end
