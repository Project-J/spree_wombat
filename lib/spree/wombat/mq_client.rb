require 'json'
require 'openssl'
require 'bunny'
require 'active_model/array_serializer'
require 'spree/wombat/client_base'

module Spree
  module Wombat
    class MqClient < ClientBase

      def initialize(object)
        super(object)
        if ENV.has_key?('RABBITMQ_BIGWIG_TX_URL')
          @conn = Bunny.new(ENV['RABBITMQ_BIGWIG_TX_URL'])
          return
        end
        @conn = Bunny.new
      end

      def self.push_batches(object)
        ex = get_exchange(object)
        @conn.start
        self.get_items(object) do |item_json|
          ex.publish item_json, :content_type => 'application/json'
        end
        @conn.stop
      end

      def self.get_exchange(object)
        @conn.exchange('projectj.spree.' + object.class.name)
      end

      def self.push(json_payload)
        ex = get_exchange(object)
        @conn.start
        ex.publish json_payload, :content_type => 'application/json'
        @conn.stop

      end
    end
  end
end
