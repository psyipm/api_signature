# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Generator do
  let(:options) do
    {
      request_method: 'GET',
      path: '/api/v1/some_path',
      access_key: 'some_access_key',
      timestamp: '1529663095'
    }
  end

  let(:secret) { 'some_secret_key' }
  let(:generator) { described_class.new(options) }

  it 'should generate signature' do
    signature = generator.generate_signature(secret)

    expect(signature).to eq 'Ek9Cy9ykxkCmV1iiOHPK1P1S21FtQL1YkPF6zAPAjzo='
  end

  it 'should be valid within time range' do
    params = options.merge(timestamp: Time.now.utc.to_i)
    generator = described_class.new(params)
    signature = generator.generate_signature(secret)

    expect(generator.valid?(signature, secret)).to eq true
  end

  it 'should not be valid if expired' do
    params = options.merge(timestamp: 5.hours.ago)
    generator = described_class.new(params)
    signature = generator.generate_signature(secret)

    expect(generator.valid?(signature, secret)).to eq false
  end
end
