# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'ostruct'

module ApiSignature
  class Builder
    OPTIONS_KEYS = [
      :access_key, :secret, :request_method, :path, :timestamp
    ].freeze

    delegate(*OPTIONS_KEYS, to: :@settings)
    delegate :expired?, to: :signature_generator

    def initialize(settings = {})
      settings = HashWithIndifferentAccess.new(settings)

      settings['timestamp'] ||= Time.now.utc.to_i.to_s
      settings['request_method'] = (settings['request_method'] || settings['method']).upcase

      @settings = OpenStruct.new(settings.select { |k, _v| OPTIONS_KEYS.include?(k.to_sym) })
    end

    def headers
      {
        'X-Access-Key' => options[:access_key],
        'X-Timestamp' => options[:timestamp],
        'X-Signature' => signature
      }
    end

    def options
      {
        timestamp: timestamp,
        request_method: request_method,
        path: path,
        access_key: access_key
      }
    end

    def signature
      @signature ||= signature_generator.generate_signature(secret)
    end

    private

    def signature_generator
      @signature_generator ||= Generator.new(options)
    end
  end
end
