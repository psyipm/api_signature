# frozen_string_literal: true

require 'api_signature/spec_support/path_builder'
require 'api_signature/spec_support/headers_builder'

module ApiSignature
  module SpecSupport
    module Helper
      include Rack::Test::Methods

      def app
        Rails.app_class
      end

      def get_with_signature(client, *args)
        with_signature(:get, client.api_key, client.api_secret, *args)
      end

      def post_with_signature(client, *args)
        with_signature(:post, client.api_key, client.api_secret, *args)
      end

      def put_with_signature(client, *args)
        with_signature(:put, client.api_key, client.api_secret, *args)
      end

      alias patch_with_signature put_with_signature

      def delete_with_signature(client, *args)
        with_signature(:delete, client.api_key, client.api_secret, *args)
      end

      private

      def with_signature(http_method, api_key, secret, action_name, params = {})
        path = PathBuilder.new(controller, action_name, params).path
        headers = HeadersBuilder.new(api_key, secret, http_method, path).headers
        custom_headers = params.delete(:headers) || {}

        send(http_method, path, params, headers.merge(custom_headers))
      end
    end
  end
end
