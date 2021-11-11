require_relative 'bcs/version'
require_relative 'bcs/errors'
require_relative 'bcs/v3/client'
require_relative 'bcs/v3/buildable'
require_relative 'bcs/v3/shipment'
require_relative 'bcs/v3/shipper'
require_relative 'bcs/v3/receiver'
require_relative 'bcs/v3/communication'
require_relative 'bcs/v3/location'
require_relative 'bcs/v3/address'
require_relative 'bcs/v3/packstation'
require_relative 'bcs/v3/parcel_shop'
require_relative 'bcs/v3/postfiliale'
require_relative 'bcs/v3/bank_data'
require_relative 'bcs/v3/service'
require_relative 'bcs/v3/locator'
require_relative 'bcs/v3/export_document'

module Dhl
  module Bcs

    def self.client(config, options = {})
      V3::Client.new(config, options)
    end

    def self.build_shipment(*args)
      V3::Shipment.build(*args)
    end

    def self.build_shipper(*args)
      V3::Shipper.build(*args)
    end

    def self.build_receiver(*args)
      V3::Receiver.build(*args)
    end

    def self.build_service(*args)
      V3::Service.new(*args)
    end

  end
end
