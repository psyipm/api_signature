# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'
require 'tempfile'

module ApiSignature
  module Utils
    # @param [File, Tempfile, IO#read, String] value
    # @return [String<SHA256 Hexdigest>]
    #
    def self.sha256_hexdigest(value)
      if (File === value || Tempfile === value) && !value.path.nil? && File.exist?(value.path)
        OpenSSL::Digest::SHA256.file(value).hexdigest
      elsif value.respond_to?(:read)
        sha256 = OpenSSL::Digest::SHA256.new

        while chunk = value.read(1024 * 1024, buffer ||= '') # 1MB
          sha256.update(chunk)
        end

        value.rewind
        sha256.hexdigest
      else
        OpenSSL::Digest::SHA256.hexdigest(value)
      end
    end

    # @param [URI] uri
    # @return [true/false]
    #
    def self.standard_port?(uri)
      (uri.scheme == 'http' && uri.port == 80) ||
        (uri.scheme == 'https' && uri.port == 443)
    end

    def self.url_path(path, uri_escape_path = false)
      path = '/' if path == ''

      if uri_escape_path
        uri_escape_path(path)
      else
        path
      end
    end

    def self.uri_escape_path(path)
      path.gsub(/[^\/]+/) { |part| uri_escape(part) }
    end

    # @api private
    def self.uri_escape(string)
      if string.nil?
        nil
      else
        CGI.escape(string.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
      end
    end

    def self.normalized_querystring(querystring)
      return unless querystring

      params = querystring.split('&')
      params = params.map { |p| p.match(/=/) ? p : p + '=' }
      # We have to sort by param name and preserve order of params that
      # have the same name. Default sort <=> in JRuby will swap members
      # occasionally when <=> is 0 (considered still sorted), but this
      # causes our normalized query string to not match the sent querystring.
      # When names match, we then sort by their original order
      params.each.with_index.sort do |a, b|
        a, a_offset = a
        a_name = a.split('=')[0]
        b, b_offset = b
        b_name = b.split('=')[0]
        if a_name == b_name
          a_offset <=> b_offset
        else
          a_name <=> b_name
        end
      end.map(&:first).join('&')
    end

    def self.canonical_header_value(value)
      value.match(/^".*"$/) ? value : value.gsub(/\s+/, ' ').strip
    end

    def self.hmac(key, value)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
    end

    def self.hexhmac(key, value)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, value)
    end

    def self.normalize_keys(hash)
      return {} unless hash

      hash.transform_keys { |key| key.to_s.downcase }
    end

    # constant-time comparison algorithm to prevent timing attacks
    def self.secure_compare(string_a, string_b)
      return false if string_a.nil? || string_b.nil? || string_a.bytesize != string_b.bytesize

      l = string_a.unpack "C#{string_a.bytesize}"

      res = 0
      string_b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end
