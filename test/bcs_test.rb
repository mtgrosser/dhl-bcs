require 'test_helper'

module Dhl
  class BcsTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil Bcs::VERSION
    end

    def test_initialize_new_client
      client = Bcs.client(user: 'user', signature: 'signature', ekp: 'ekp12345', participation_number: '01', api_user: 'test', api_pwd: 'test',
                          test: true, log: true)
      assert_equal Bcs::V3::Client, client.class
    end

    def test_build_shipper
      shipper = Bcs.build_shipper(name: 'Christoph Wagner',
        company: 'webit! Gesellschaft für neue Medien mbH',
        street_name: 'Schandauer Straße',
        street_number: '34',
        zip: '01309',
        city: 'Dresden',
        country_code: 'DE',
        email: 'wagner@webit.de')

      assert_equal 'Christoph Wagner', shipper.name
      assert_equal 'webit! Gesellschaft für neue Medien mbH', shipper.company

      assert_equal 'Schandauer Straße', shipper.address.street_name
      assert_equal '34', shipper.address.street_number
      assert_equal '01309', shipper.address.zip
      assert_equal 'Dresden', shipper.address.city
      assert_equal 'DE', shipper.address.country_code

      assert_equal 'wagner@webit.de', shipper.communication.email
    end

    def test_build_receiver

    end

  end
end
