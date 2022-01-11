require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'pry'

require 'webmock/minitest'
require 'minitest/autorun'

class Minitest::Test

  def before_setup
    stub_request(:get, "https://cig.dhl.de/cig-wsdls/com/dpdhl/wsdl/geschaeftskundenversand-api/2.0/geschaeftskundenversand-api-2.0.wsdl").
      to_return(body: File.read('test/stubs/geschaeftskundenversand-api-2.0.wsdl'))
  end

end
