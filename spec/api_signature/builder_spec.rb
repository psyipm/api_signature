# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Builder do
  let(:env) do
    {
      access_key: 'api_key',
      secret: 'api_secret',
      request_method: 'GET',
      scheme: 'https',
      host: 'localhost',
      port: '3000',
      path: '/api/v1/some_path',
      params: 'key1=value',
      timestamp: '1503658902'
    }
  end

  let(:builder) { described_class.new(env) }

  it 'should respond to options keys methods' do
    env.keys.each do |key|
      expect(builder.respond_to?(key)).to eq true
      expect(builder.send(key)).to eq env[key]
    end
  end

  it 'should return headers hash' do
    expect(builder.headers['X-Access-Key']).to eq env[:access_key]
    expect(builder.headers['X-Timestamp']).to eq env[:timestamp]
    expect(builder.headers['X-Signature']).to_not be_empty
  end

  it 'should return options hash' do
    expect(builder.options[:timestamp]).to eq env[:timestamp]
    expect(builder.options[:request_method]).to eq env[:request_method]
    expect(builder.options[:path]).to eq env[:path]
    expect(builder.options[:access_key]).to eq env[:access_key]
  end

  it 'should build url' do
    expect(builder.url.to_s).to eq 'https://localhost:3000/api/v1/some_path'
  end

  it 'should generate signature' do
    expect(builder.signature).to eq 'Sk5K4yDanrSK+TIa9LWMxRMnkl5DAxpb6Qi9Mm3Msf4='
  end

  it 'should delegate `expired?` to signature' do
    params = env.merge(timestamp: Time.zone.now.to_i)
    builder = described_class.new(params)

    expect(builder.expired?).to eq false
  end
end
