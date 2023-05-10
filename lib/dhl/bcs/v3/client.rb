require 'savon'
require 'stringio'
require 'logger'
require 'pathname'

module Dhl::Bcs::V3
  class Client
    MAJOR = '3'.freeze
    MINOR = '1'.freeze
    PATCH = '8'.freeze
    API_VERSION = [MAJOR, MINOR, PATCH].join('.').freeze

    # 'https://cig.dhl.de/cig-wsdls/com/dpdhl/wsdl/geschaeftskundenversand-api/2.0/geschaeftskundenversand-api-2.0.wsdl'
    WSDL = Pathname.new(__FILE__).dirname.join('..', '..', '..', '..', 'wsdl', "geschaeftskundenversand-api-#{API_VERSION}.wsdl").realpath.to_s

    def initialize(user:, signature:, ekp:, participation_number:, api_user:, api_pwd:, log: true, test: false)
      @ekp = ekp
      @participation_number = participation_number

      @logIO = StringIO.new
      @logger = log && Logger.new($stdout)

      @client = Savon.client({
        endpoint: (test ? 'https://cig.dhl.de/services/sandbox/soap' : 'https://cig.dhl.de/services/production/soap'),
        wsdl: WSDL,
        basic_auth: [api_user, api_pwd],
        logger: Logger.new(@logIO),
        log: true,
        soap_header: {
          'cis:Authentification' => {
            'cis:user' => user,
            'cis:signature' => signature,
            'cis:type' => 0
          }
        },
        namespaces: { 'xmlns:cis' => 'http://dhl.de/webservice/cisbase' }
      })
    end

    def get_version(major: MAJOR, minor: MINOR, build: nil)
      request(:get_version,
        'bcs:Version' => {
          'majorRelease' => major,
          'minorRelease' => minor
        }.tap { |h| h['build'] = build if build }
      ) do |response|
        response.body[:get_version_response][:version]
      end
    end

    def validate_shipment(*shipments, **options)
      request(:validate_shipment, build_shipment_orders(shipments, **options)) do |response|
        [response.body[:validate_shipment_response][:validation_state]].flatten.map do |validation_state|
          validation_state[:status]
        end
      end
    end

    def create_shipment_order(*shipments, **options)
      request(:create_shipment_order, build_shipment_orders(shipments, **options)) do |response|
        [response.body[:create_shipment_order_response][:creation_state]].flatten
      end
    end

    def update_shipment_order(shipment_number, shipment, **options)
      request(:update_shipment_order, { 'cis:shipmentNumber' => shipment_number }.merge(build_shipment_orders([shipment], **options))) do |response|
        clean_response_data(response.body[:update_shipment_order_response][:label_data])
      end
    end

    def delete_shipment_order(*shipment_numbers)
      raise Dhl::Bcs::DataError, 'No more than 30 shipment_numbers allowed per request!' if shipment_numbers.size > 30
      request(:delete_shipment_order, 'cis:shipmentNumber' => shipment_numbers) do |response|
        array_wrap(response.body.dig(:delete_shipment_order_response, :deletion_state)).inject({}) do |h, data|
          h.update(data[:shipment_number] => data[:status])
        end
      end
    end

    {
      get_label: :label_data,
      get_export_doc: :export_doc_data,
      do_manifest: :manifest_state
    }.each do |api_method, response_key|
      define_method api_method do |*shipment_numbers|
        raise Dhl::Bcs::DataError, 'No more than 30 shipment_numbers allowed per request!' if shipment_numbers.size > 30
        request(api_method, 'cis:shipmentNumber' => shipment_numbers) do |response|
          h = {}
          [response.body[:"#{api_method}_response"][response_key]].flatten.each do |data|
            h[data.delete(:shipment_number)] = clean_response_data(data)
          end
          h
        end
      end
    end

    # returns base64 encoded PDF document
    def get_manifest(date)
      request(:get_manifest, 'manifestDate' => date) do |response|
        response.body[:get_manifest_response][:manifest_data]
      end
    end

    def last_log
      @logIO.string
    end

    protected

    def build_shipment_orders(shipments, label_response_type: 'URL', print_only_if_codeable: false)
      raise Dhl::Bcs::DataError, 'No more than 30 shipments allowed per request!' if shipments.size > 30
      {
        'ShipmentOrder' => shipments.map.with_index(1) { |shipment, index|
          {
            'sequenceNumber' => format('%02i', index.to_s),
            'Shipment' => shipment.to_soap_hash(@ekp, @participation_number),
            'PrintOnlyIfCodeable/' => { '@active': print_only_if_codeable ? 1 : 0 }
          }
        },
        'labelResponseType' => label_response_type.to_s.upcase
      }
    end

    def request(action, message = {})
      @logIO.string = ''
      response = @client.call(action, message: {
        'bcs:Version' => {
          'majorRelease' => MAJOR,
          'minorRelease' => MINOR
        }
      }.merge(message))
      @logger << @logIO.string if @logger
      yield response
    rescue
      raise Dhl::Bcs::RequestError, @logIO.string
    end

    def clean_response_data(data)
      data.delete(:@xmlns)
      data
    end

    def array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end

  end
end
