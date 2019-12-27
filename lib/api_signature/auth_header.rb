# frozen_string_literal: true

module ApiSignature
  class AuthHeader
    attr_reader :authorization

    TOKEN_REGEX = /^(API-HMAC-SHA256)\s+/.freeze
    AUTHN_PAIR_DELIMITERS = /(?:,|\t+)/.freeze

    def initialize(authorization)
      @authorization = authorization
    end

    def credential
      data[0]
    end

    def signature
      options['Signature']
    end

    def signed_headers
      return [] unless options['SignedHeaders']

      @signed_headers ||= options['SignedHeaders'].split(/;\s?/).map(&:strip)
    end

    def options
      @options ||= (data[1] || {})
    end

    private

    def data
      @data ||= (parse_token_with_options || [])
    end

    def parse_token_with_options
      return unless authorization[TOKEN_REGEX]

      params = token_params_from authorization
      [params.shift[1], Hash[params]]
    end

    def token_params_from(auth)
      rewrite_param_values params_array_from raw_params(auth)
    end

    def raw_params(auth)
      auth.sub(TOKEN_REGEX, '').split(/\s*#{AUTHN_PAIR_DELIMITERS}\s*/)
    end

    def params_array_from(raw_params)
      raw_params.map { |param| param.split(/=(.+)?/) }
    end

    def rewrite_param_values(array_params)
      array_params.each { |param| (param[1] || +'').gsub!(/^"|"$/, '') }
    end
  end
end
