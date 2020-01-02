# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Configuration do
  let(:config) { described_class.new }

  it 'must set default value' do
    expect(config.signature_ttl).not_to eq nil
  end

  it 'must set custom value' do
    config.signature_ttl = 1
    expect(config.signature_ttl).to eq 1
  end
end
