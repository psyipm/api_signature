# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

module ApiSignature
  # Usage:
  #  request = Signature.new(options)
  #  request.valid?('some-signature-hash', 'some-big-secret-key',)
  #
  class Signature
    SPLITTER = '|'
    TTL = 2.hours

    def initialize(options = {})
      @options = options
      @timestamp = Time.zone.at(@options[:timestamp].to_i)
    end

    def valid?(signature, secret)
      return false if signature.blank? || secret.blank? || expired?
      generate_signature(secret) == signature
    end

    def invalid?(*args)
      !valid?(*args)
    end

    def expired?
      !alive?
    end

    def alive?
      alive_timerange.cover?(@timestamp)
    end

    def alive_timerange
      @alive_timerange ||= (TTL.ago..TTL.from_now)
    end

    def generate_signature(secret)
      hmac = OpenSSL::HMAC.digest(digest, secret, string_to_sign)
      Base64.encode64(hmac).chomp
    end

    protected

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def string_to_sign
      [
        @options[:request_method],
        @options[:path],
        @options[:access_key],
        @timestamp.to_i
      ].map(&:to_s).join(SPLITTER)
    end
  end
end
