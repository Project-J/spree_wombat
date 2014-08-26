require 'active_model/serializer'

module Spree
  module Wombat
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :email, :updated_at, :created_at

      has_one :shipping_address, serializer: Spree::Wombat::AddressSerializer
      has_one :billing_address, serializer: Spree::Wombat::AddressSerializer

      def updated_at
        object.updated_at.getutc.try(:iso8601)
      end

      def created_at
        object.created_at.getutc.try(:iso8601)
      end

    end
  end
end


