require 'json'
require 'openssl'
require 'bunny'
require 'active_model/array_serializer'
require 'spree/wombat/client_base'

module Spree
  module Wombat
    class MqClient < ClientBase

      def initialize
        if ENV.has_key?('RABBITMQ_BIGWIG_TX_URL')
          @conn = Bunny.new(ENV['RABBITMQ_BIGWIG_TX_URL'])
          return
        end
        @conn = Bunny.new
      end

      def push_batches(object)
        items = get_items(object)
        unless items.any?
          update_last_pushed(object)
          return
        end
        @conn.start
        ex = get_exchange(object)
        items.each do |item_json|
          ex.publish item_json, :content_type => 'application/json'
        end
        @conn.stop
        update_last_pushed(object)
      end

      def get_exchange(object)
        @conn.queue('ProjectJ::' + object)
      end

      def push(json_payload)
        ex = get_exchange(object)
        @conn.start
        ex.publish json_payload, :content_type => 'application/json'
        @conn.stop
      end
    end
  end
end
