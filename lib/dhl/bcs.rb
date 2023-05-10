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

    class << self
      def client(*args, **kwargs)
        V3::Client.new(*args, **kwargs)
      end

      %i[Shipment Shipper Receiver Service].each do |name|
        define_method "build_#{name.to_s.downcase}" do |*args, **kwargs|
          V3.const_get(name).build(*args, **kwargs)
        end
      end
    end

  end
end
