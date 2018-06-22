# frozen_string_literal: true

module ApiSignature
  class Validator
    attr_reader :timestamp

    def initialize(options)
      @options = options
      @timestamp = Time.zone.at(@options[:timestamp].to_i)
    end

    def valid?(signature, secret)
      return false if signature.blank? || secret.blank? || expired?
      generator.generate_signature(secret) == signature
    end

    def expired?
      !alive?
    end

    private

    def generator
      @generator ||= Generator.new(@options)
    end

    def alive?
      alive_timerange.cover?(timestamp)
    end

    def alive_timerange
      @alive_timerange ||= (ttl.ago..ttl.from_now)
    end

    def ttl
      ApiSignature.signature_ttl || TTL
    end
  end
end
