# frozen_string_literal: true

module ApiSignature
  module SpecSupport
    class HeadersBuilder
      attr_reader :access_key, :secret, :http_method, :path

      def initialize(access_key, secret, http_method, path)
        @access_key = access_key
        @secret = secret
        @http_method = http_method
        @path = path
      end

      def headers
        {
          'HTTP_X_ACCESS_KEY' => access_key,
          'HTTP_X_TIMESTAMP' => options[:timestamp],
          'HTTP_X_SIGNATURE' => generator.generate_signature(secret)
        }
      end

      private

      def generator
        @generator ||= ::ApiSignature::Generator.new(options)
      end

      def options
        @options ||= {
          request_method: http_method.to_s.upcase,
          path: path,
          access_key: access_key,
          timestamp: Time.zone.now.to_i
        }
      end
    end
  end
end
