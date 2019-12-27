# frozen_string_literal: true

require 'set'

module ApiSignature
  # The signer requires secret key.
  #
  #     signer = ApiSignature::Signer.new('access key', 'secret key', uri_escape_path: true)
  #
  class Signer
    NAME = 'API-HMAC-SHA256'

    # Options:
    # @option options [Array<String>] :unsigned_headers ([]) A list of
    #   headers that should not be signed. This is useful when a proxy
    #   modifies headers, such as 'User-Agent', invalidating a signature.
    #
    # @option options [Boolean] :uri_escape_path (true) When `true`,
    #   the request URI path is uri-escaped as part of computing the canonical
    #   request string.
    #
    # @option options [Boolean] :apply_checksum_header (false) When `true`,
    #   the computed content checksum is returned in the hash of signature
    #   headers.
    #
    # @option options [String] :signature_header (authorization) Header name
    #   for signature
    #
    def initialize(access_key, secret_key, options = {})
      @access_key = access_key
      @secret_key = secret_key
      @options = options
    end

    # Computes a signature. Returns the resultant
    # signature as a hash of headers to apply to your HTTP request. The given
    # request is not modified.
    #
    #     signature = signer.sign_request(
    #       http_method: 'PUT',
    #       url: 'https://domain.com',
    #       headers: {
    #         'Abc' => 'xyz',
    #       },
    #       body: 'body' # String or IO object
    #     )
    # @param [Hash] request
    #
    # @option request [required, String] :http_method One of
    #   'GET', 'HEAD', 'PUT', 'POST', 'PATCH', or 'DELETE'
    #
    # @option request [required, String, URI::HTTPS, URI::HTTP] :url
    #   The request URI. Must be a valid HTTP or HTTPS URI.
    #
    # @option request [optional, Hash] :headers ({}) A hash of headers
    #   to sign. If the 'X-Amz-Content-Sha256' header is set, the `:body`
    #   is optional and will not be read.
    #
    # @option request [optional, String, IO] :body ('') The HTTP request body.
    #   A sha256 checksum is computed of the body unless the
    #   'X-Amz-Content-Sha256' header is set.
    #
    # @return [Signature] Return an instance of {Signature} that has
    #   a `#headers` method. The headers must be applied to your request.
    def sign_request(request)
      builder = Builder.new(request, unsigned_headers)
      sig_headers = builder.build_sign_headers(apply_checksum_header?)
      data = build_signature(builder)

      # apply signature
      sig_headers[signature_header_name] = data[:header]

      # Returning the signature components.
      Signature.new(data.merge!(headers: sig_headers))
    end

    private

    def uri_escape_path?
      @options[:uri_escape_path] == true || !@options.key?(:uri_escape_path)
    end

    def apply_checksum_header?
      @options[:apply_checksum_header] == true
    end

    def signature_header_name
      @options[:signature_header] || ApiSignature.configuration.signature_header
    end

    def unsigned_headers
      @unsigned_headers ||= build_unsigned_headers
    end

    def build_unsigned_headers
      Set.new(@options.fetch(:unsigned_headers, []).map(&:downcase)) << 'authorization'
    end

    def build_signature(builder)
      path = Utils.url_path(builder.uri.path, uri_escape_path?)

      # compute signature parts
      creq = builder.canonical_request(path)
      sts = string_to_sign(builder.datetime, creq)
      sig = signature(builder.date, sts)

      {
        header: build_signature_header(builder, sig),
        content_sha256: builder.content_sha256,
        string_to_sign: sts,
        canonical_request: creq,
        signature: sig
      }
    end

    def build_signature_header(builder, signature)
      [
        "#{NAME} Credential=#{credential(builder.date)}",
        "SignedHeaders=#{builder.signed_headers_names}",
        "Signature=#{signature}"
      ].join(', ')
    end

    def string_to_sign(datetime, canonical_request)
      [
        NAME,
        datetime,
        Utils.sha256_hexdigest(canonical_request)
      ].join(Builder::SPLITTER)
    end

    def signature(date, string_to_sign)
      k_date = Utils.hmac('API' + @secret_key, date)
      k_credentials = Utils.hmac(k_date, 'api_request')

      Utils.hexhmac(k_credentials, string_to_sign)
    end

    def credential(date)
      "#{@access_key}/#{date}/api_request"
    end
  end
end
