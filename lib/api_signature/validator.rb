# frozen_string_literal: true

module ApiSignature
  # Validate a request
  #
  #     request = {
  #       http_method: 'PUT',
  #       url: 'https://domain.com',
  #       headers: {
  #         'Authorization' => 'API-HMAC-SHA256 Credential=access_key/20191227/api_request...',
  #         'Host' => 'example.com,
  #         'X-Content-Sha256' => '...',
  #         'X-Datetime' => '2019-12-27T09:13:14.873+0000'
  #       },
  #       body: 'body'
  #     }
  #     validator = ApiSignature::Validator.new(request, uri_escape_path: true)
  #     validator.access_key # get key from request headers
  #
  #
  class Validator
    attr_reader :request

    def initialize(request, options = {})
      @request = request
      @options = options
    end

    def headers
      @headers ||= Utils.normalize_keys(request[:headers])
    end

    def access_key
      @access_key ||= auth_header.credential.split('/')[0]
    end

    def auth_header
      @auth_header ||= AuthHeader.new(headers[signature_header_name])
    end

    # Validate a signature. Returns boolean
    #
    #     validator.valid?('secret_key_here')
    #
    # @param [String] secret key
    #
    def valid?(secret_key)
      valid_timestamp? && valid_signature?(secret_key)
    end

    def valid_timestamp?
      timestamp && ttl_range.cover?(timestamp)
    end

    def valid_signature?(secret_key)
      Utils.secure_compare(
        auth_header.signature,
        server_token.signature
      )
    end

    private

    def signature_header_name
      @options[:signature_header] || ApiSignature.configuration.signature_header
    end

    def timestamp
      @timestamp ||= Utils.safe_parse_datetime(headers['x-datetime'])
    end

    def ttl_range
      to = Time.now.utc
      from = to - ApiSignature.configuration.signature_ttl

      from..to
    end
  end
end
