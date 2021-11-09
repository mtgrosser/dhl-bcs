# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dhl/bcs/version'

Gem::Specification.new do |spec|
  spec.name          = "dhl-bcs"
  spec.version       = Dhl::Bcs::VERSION
  spec.authors       = ["Christoph Wagner"]
  spec.email         = ["wagner@webit.de"]

  spec.summary       = %q{Client for DHL Business-Customer-Shipping SOAP API 3.1}
  spec.description   = %q{This is inspired by the dhl-intraship gem that is a little bit outdated and doesn't support the new DHL API. If you need DHL Express Services this is not for you.}
  spec.homepage      = "https://github.com/webit-de/dhl-bcs"
  spec.license       = "MIT"

  spec.files         = Dir['{lib,wsdl}/**/*.{rb,wsdl,xsd}', 'LICENSE.txt', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.12"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "pry-byebug", "~> 3.6"
end
