require "spec_helper"

module Spree
  module Wombat
    describe OrderSerializer do

      let(:user) { create(:user) }
      let!(:order) { create(:shipped_order, :user => user) }
      let(:serialized_user) { JSON.parse (UserSerializer.new(user, :root => false).to_json) }
      let(:serialized_order_no_user) {
        JSON.parse(OrderSerializer.new(create(:shipped_order_no_user), root: false).to_json)
      }

      let(:serialized_order) do
        JSON.parse(OrderSerializer.new(order, root: false).to_json)
      end

      context "format" do

        it "uses the order number for id" do
          expect(serialized_order["id"]).to eql order.number
        end

        it "uses status for the state" do
          expect(serialized_order["status"]).to eql order.state
        end

        it "sets the channel to spree" do
          expect(serialized_order["channel"]).to eql "spree"
        end

        it "set's the placed_on to completed_at date in ISO format" do
          expect(serialized_order["placed_on"]).to match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
        end

        it "checks user is associated with order" do
          expect(serialized_order["user"]).to eql serialized_user
        end

        it "checks no user is associated with order" do
          expect(serialized_order_no_user["user"]).to eql nil
        end

        context "totals" do

          let(:totals) do
            {
              "item"=> 50.0,
              "adjustment"=> 0.0,
              "tax"=> 0.0,
              "shipping"=> 100.0,
              "payment"=> 150.0,
              "order"=> 150.0
            }
          end

          it "has all the amounts for the order" do
            expect(serialized_order["totals"]).to eql totals
          end
        end

        context "adjustments key" do
          it "shipment matches order shipping total value" do
            shipping_hash = serialized_order["adjustments"].select { |a| a["name"] == "shipping" }.first
            expect(shipping_hash["value"]).to eq order.shipment_total.to_f
          end

          context 'discount' do
            before do
              create(:adjustment, adjustable: order, source_type: 'Spree::PromotionAction', amount: -10)
              create(:adjustment, adjustable: order.line_items.first, source_type: 'Spree::PromotionAction', amount: -10)
              create(:adjustment, adjustable: order.shipments.first, source_type: 'Spree::PromotionAction', amount: -10)
              order.update_totals
            end

            it "discount matches order promo total value" do
              discount_hash = serialized_order["adjustments"].select { |a| a["name"] == "discount" }.first
              expect(discount_hash["value"]).to eq order.adjustment_total.to_f
            end
          end
        end
      end
    end
  end
end
