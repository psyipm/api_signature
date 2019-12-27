# frozen_string_literal: true

require 'api_signature/version'
require 'api_signature/configuration'

module ApiSignature
  autoload :Builder, 'api_signature/builder'
  autoload :Validator, 'api_signature/validator'
  autoload :Generator, 'api_signature/generator'
  autoload :Request, 'api_signature/request'
  autoload :Signer, 'api_signature/signer'
  autoload :Signature, 'api_signature/signature'
  autoload :Utils, 'api_signature/utils'

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  # @example
  #   ApiSignature.setup do |config|
  #     config.signature_ttl = 2.minutes
  #   end
  #
  def self.setup
    yield configuration
  end
end
