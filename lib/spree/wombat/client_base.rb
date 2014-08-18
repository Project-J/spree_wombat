require 'json'
require 'active_model/array_serializer'

module Spree
  module Wombat
    class ClientBase

      def initialize(object)
        @last_push_time = Spree::Wombat::Config[:last_pushed_timestamps][object] || Time.now
        @this_push_time = touch_last_pushed(object)
        @payload_builder = Spree::Wombat::Config[:payload_builder][object]
      end

      def self.get_items(object, datetime_column: 'updated_at', batch_size: 10)
        scope = object.constantize
        # unless filter != @payload_builder[:filter]
        #   raise Exception
        # end
        # scope.send(filter.to_sym)
        if filter = payload_builder[:filter]
          scope = scope.send(filter.to_sym)
        end
        items = []
        scope.where(datetime_column.to_sym => @last_push_time..@this_push_time).find_in_batches(batch_size: batch_size) do |batch|
          items << serilize(batch)
        end
        items
      end

      def self.serilize(batch)
        ActiveModel::ArraySerializer.new(
            batch,
            each_serializer: @payload_builder[:serializer].constantize,
            root: @payload_builder[:root]
        ).to_json
      end

      def self.push_batches(object)
        raise NoMethodError
      end

      def self.push(json_payload)
        raise NoMethodError
      end

      def self.validate(res)
        raise NoMethodError
      end

      private
      def self.touch_last_pushed(object)
        last_pushed_ts = Spree::Wombat::Config[:last_pushed_timestamps]
        last_pushed_ts[object] = Time.now
        Spree::Wombat::Config[:last_pushed_timestamps] = last_pushed_ts
        last_pushed_ts[object]
      end

    end
  end
end
