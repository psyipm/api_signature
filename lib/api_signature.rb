# frozen_string_literal: true

require 'api_signature/version'
require 'active_support/time'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/try'

module ApiSignature
  autoload :Builder, 'api_signature/builder'
  autoload :Validator, 'api_signature/validator'
  autoload :Generator, 'api_signature/generator'
  autoload :Request, 'api_signature/request'

  # Time to live for generated signature
  mattr_accessor :signature_ttl
  self.signature_ttl = 2.hours

  # @example
  #   ApiSignature.setup do |config|
  #     config.signature_ttl = 2.minutes
  #   end
  #
  def self.setup
    yield self
  end
end
