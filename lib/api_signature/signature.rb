# frozen_string_literal: true

module ApiSignature
  class Signature
    # @return [Hash<String,String>] A hash of headers that should
    #   be applied to the HTTP request. Header keys are lower
    #   cased strings and may include the following:
    #
    #   * 'host'
    #   * 'x-date'
    #   * 'x-content-sha256'
    #   * 'authorization'
    #
    attr_reader :headers

    # @return [String] For debugging purposes.
    attr_reader :canonical_request

    # @return [String] For debugging purposes.
    attr_reader :string_to_sign

    # @return [String] For debugging purposes.
    attr_reader :content_sha256

    def initialize(attributes)
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
