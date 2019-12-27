# frozen_string_literal: true

require 'uri'

module ApiSignature
  class Builder
    attr_reader :settings

    SPLITTER = "\n"

    def initialize(settings = {}, unsigned_headers = [])
      @settings = settings
      @unsigned_headers = unsigned_headers
    end

    def http_method
      @http_method ||= extract_http_method
    end

    def uri
      @uri ||= extract_uri
    end

    def host
      @host ||= extract_host_from_uri
    end

    def headers
      @headers ||= Utils.normalize_keys(settings[:headers])
    end

    def datetime
      @datetime ||= extract_datetime
    end

    def date
      @date ||= datetime.to_s.scan(/\d/).take(8).join
    end

    def content_sha256
      @content_sha256 ||= (headers['x-content-sha256'] || Utils.sha256_hexdigest(body))
    end

    def body
      @body ||= (settings[:body] || '')
    end

    def build_sign_headers(apply_checksum_header = false)
      @sign_headers = {
        'host' => host,
        'x-datetime' => datetime
      }
      @sign_headers['x-content-sha256'] = content_sha256 if apply_checksum_header
      @sign_headers
    end

    def full_headers
      @full_headers ||= merge_sign_with_origin_headers
    end

    def signed_headers
      @signed_headers ||= full_headers.reject { |key, _value| @unsigned_headers.include?(key) }
    end

    def signed_headers_names
      @signed_headers_names ||= signed_headers.keys.sort.join(';')
    end

    def canonical_request(path)
      [
        http_method,
        path,
        Utils.normalized_querystring(uri.query),
        canonical_headers + SPLITTER,
        signed_headers_names,
        content_sha256
      ].join(SPLITTER)
    end

    private

    def extract_http_method
      raise ArgumentError, 'missing required option :http_method' unless settings[:http_method]

      settings[:http_method].to_s.upcase
    end

    def extract_uri
      raise ArgumentError, 'missing required option :url' unless settings[:url]

      URI.parse(settings[:url].to_s)
    end

    def extract_host_from_uri
      if Utils.standard_port?(uri)
        uri.host
      else
        "#{uri.host}:#{uri.port}"
      end
    end

    def extract_datetime
      headers['x-datetime'] || Time.now.utc.strftime(ApiSignature.configuration.datetime_format)
    end

    def merge_sign_with_origin_headers
      raise ArgumentError, 'missing required variable sign_headers' unless @sign_headers

      # merge so we do not modify given headers hash
      headers.merge(@sign_headers)
    end

    def canonical_headers
      signed_headers.sort_by(&:first)
                    .map { |k, v| "#{k}:#{Utils.canonical_header_value(v.to_s)}" }
                    .join(SPLITTER)
    end
  end
end
