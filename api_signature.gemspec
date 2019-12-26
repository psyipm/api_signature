# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_signature/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_signature'
  spec.version       = ApiSignature::VERSION
  spec.authors       = ['Igor Galeta', 'Igor Malinovskiy']
  spec.email         = ['igor.malinovskiy@netfix.xyz']

  spec.summary       = 'Sign API requests with HMAC signature'
  spec.homepage      = 'https://github.com/psyipm/api_signature'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'guard-rspec', '~> 4.7', '>= 4.7.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rb-fsevent', '0.9.8'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
