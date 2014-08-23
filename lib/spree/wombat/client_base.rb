require 'json'
require 'active_model/array_serializer'

module Spree
  module Wombat
    class ClientBase

      def set_constraints(object)
        now = Time.zone.now
        @last_push_time = Spree::Wombat::Config[:last_pushed_timestamps][object] || now - 1.hour
        @push_start_time = now
        @payload_builder = Spree::Wombat::Config[:payload_builder][object]
      end

      def get_items(object, datetime_column: 'updated_at', batch_size: 10)
        set_constraints(object)
        scope = object.constantize
        # unless filter != @payload_builder[:filter]
        #   raise Exception
        # end
        # scope.send(filter.to_sym)
        if filter = @payload_builder[:filter]
          scope = scope.send(filter.to_sym)
        end
        items = []
        scope.where(datetime_column.to_sym => @last_push_time..@push_start_time).find_in_batches(batch_size: batch_size) do |batch|
          items << serilize(batch)
        end
        items
      end

      def serilize(batch)
        ActiveModel::ArraySerializer.new(
            batch,
            each_serializer: @payload_builder[:serializer].constantize,
            root: @payload_builder[:root]
        ).to_json
      end

      def push_batches(object)
        raise NoMethodError
      end

      def push(json_payload)
        raise NoMethodError
      end

      def update_last_pushed(object)
        last_pushed_ts = Spree::Wombat::Config[:last_pushed_timestamps]
        last_pushed_ts[object] = @push_start_time
        Spree::Wombat::Config[:last_pushed_timestamps] = last_pushed_ts
      end
    end
  end
end
