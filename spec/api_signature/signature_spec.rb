# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature::Signature do
  let(:attributes) do
    {
      headers: 'headers',
      string_to_sign: 'string_to_sign',
      canonical_request: 'canonical_request',
      content_sha256: 'content_sha256'
    }
  end
  let(:signature) { described_class.new(attributes) }

  it 'must set attribute readers' do
    attributes.each do |key, value|
      expect(signature.send(key)).to eq value
    end
  end
end
