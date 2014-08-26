require 'active_model/serializer'

module Spree
  module Wombat
    class AddressSerializer < ActiveModel::Serializer
      attributes :id, :firstname, :lastname, :address1, :address2, :zipcode, :city,
                 :state, :country, :phone, :updated_at, :created_at

      def updated_at
        object.updated_at.getutc.try(:iso8601)
      end

      def created_at
        object.created_at.getutc.try(:iso8601)
      end

      def country
        object.country.iso
      end

      def state
        if object.state
          object.state.abbr
        else
          object.state_name
        end
      end

    end
  end
end
