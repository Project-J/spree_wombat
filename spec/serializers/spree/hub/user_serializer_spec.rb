require 'spec_helper'

module Spree
  module Wombat
    describe UserSerializer do
      let(:address) { create(:address) }
      let(:serialized_address) { JSON.parse (AddressSerializer.new(address, :root => false).to_json) }
      let(:user) { create(:user, :ship_address => address, :bill_address => address) }
      let(:serialized_user) { JSON.parse (UserSerializer.new(user, :root => false).to_json) }

      context 'format' do
        it 'checks basic serialization' do
          expect(serialized_user['id']).to eql user.id
        end

        it 'checkes the billing_address has been serialized' do
          expect(serialized_user['billing_address']).to eql serialized_address
        end

        it 'checkes the shipping_address has been serialized' do
          expect(serialized_user['shipping_address']).to eql serialized_address
        end

        it 'checks that dates are in ISO format' do
          regexp = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
          expect(serialized_user['updated_at']).to match regexp
          expect(serialized_user['created_at']).to match regexp
        end

      end
    end
  end
end
