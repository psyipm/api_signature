# frozen_string_literal: true

module ApiSignature
  class Configuration
    attr_accessor :signature_ttl, :signature_header, :datetime_format, :service

    def initialize
      @signature_ttl = 5 * 60
      @datetime_format = '%Y-%m-%dT%H:%M:%S.%L%z'
      @signature_header = 'authorization'
      @service = 'web'
    end
  end
end
