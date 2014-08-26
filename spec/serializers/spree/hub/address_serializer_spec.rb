require "spec_helper"

module Spree
  module Wombat
    describe AddressSerializer do

      let(:address) { create(:address) }
      let(:serialized_address) { JSON.parse(AddressSerializer.new(address, root: false).to_json) }

      it "serializes the country iso" do
        expect(serialized_address["country"]).to eql address.country.iso
      end

      it "serializes the state name" do
        expect(serialized_address['state']).to eql address.state.abbr
      end

      context "when address has state_name, but not state" do
        before do
          address.state = nil
          address.state_name = 'Victoria'
        end

        it "uses state_name" do
         expect(serialized_address['state']).to eql address.state_name
        end

        it 'checks that dates are in ISO format' do
          regexp = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
          expect(serialized_address['updated_at']).to match regexp
          expect(serialized_address['created_at']).to match regexp
        end
      end
    end
  end
end
