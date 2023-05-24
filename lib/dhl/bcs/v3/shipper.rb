module Dhl::Bcs::V3
  class Shipper
    include Buildable
    
    PROPERTIES = %i(name company company_addition address communication).freeze

    attr_accessor(*PROPERTIES)

    def self.build(**attributes)
      # FIXME: company goes where?
      attributes = attributes.dup
      company = attributes.delete(:company)
      address = Address.build(**attributes)
      communication = Communication.build(**attributes)
      new(**attributes.merge(address: address, communication: communication, company: company))
    end

    def to_soap_hash
      {
        'Name' => { 'cis:name1' => name }.tap { |h|
          h['cis:name2'] = company if company
          h['cis:name3'] = company_addition if company_addition
        },
        'Address' => address.to_soap_hash,
        'Communication' => communication.to_soap_hash
      }
    end

  end
end
