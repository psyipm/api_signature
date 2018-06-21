# frozen_string_literal: true

require 'rack/request'

module ApiSignature
  class ApiRequest < ::Rack::Request
    KEYS = %w[X-Access-Key X-Signature X-Timestamp].freeze

    HEADER_KEYS = {
      access_key: 'HTTP_X_ACCESS_KEY',
      signature:  'HTTP_X_SIGNATURE',
      timestamp:  'HTTP_X_TIMESTAMP'
    }.freeze

    def correct?(token, secret)
      access_key == token && validator.valid?(signature, secret)
    end

    def valid?
      timestamp.present? && signature.present? && access_key.present?
    end

    def timestamp
      @timestamp ||= @env[HEADER_KEYS[:timestamp]]
    end

    def signature
      @signature ||= @env[HEADER_KEYS[:signature]]
    end

    def access_key
      @access_key ||= @env[HEADER_KEYS[:access_key]]
    end

    protected

    def validator
      @validator ||= Signature.new(validator_params)
    end

    def validator_params
      {
        request_method: request_method,
        path: path,
        access_key: access_key,
        timestamp: timestamp
      }
    end
  end
end
