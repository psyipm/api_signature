# frozen_string_literal: true

module ApiSignature
  class Configuration
    attr_accessor :signature_ttl, :signature_header, :datetime_format

    def initialize
      @signature_ttl = 2 * 60
      @datetime_format = '%Y-%m-%dT%H:%M:%S.%L%z'
      @signature_header = 'authorization'
    end
  end
end
