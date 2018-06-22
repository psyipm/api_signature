# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

module ApiSignature
  class Generator
    SPLITTER = '|'
    TTL = 2.hours

    delegate :valid?, :expired?, :timestamp, to: :validator

    def initialize(options = {})
      @options = options
    end

    def generate_signature(secret)
      hmac = OpenSSL::HMAC.digest(digest, secret, string_to_sign)
      Base64.encode64(hmac).chomp
    end

    private

    def validator
      Validator.new(@options)
    end

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def string_to_sign
      [
        @options[:request_method],
        @options[:path],
        @options[:access_key],
        timestamp.to_i
      ].map(&:to_s).join(SPLITTER)
    end
  end
end
