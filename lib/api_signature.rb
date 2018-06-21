# frozen_string_literal: true

require 'api_signature/version'
require 'active_support/time'
require 'active_support/time_with_zone'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/try'

module ApiSignature
  autoload :Signature, 'api_signature/signature'
  autoload :ApiRequest, 'api_signature/api_request'
end
