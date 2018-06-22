# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiSignature do
  it 'has a version number' do
    expect(ApiSignature::VERSION).not_to be nil
  end
end
