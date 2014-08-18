require 'json'
require 'openssl'
require 'httparty'
require 'active_model/array_serializer'
require 'spree/wombat/client_base'

module Spree
  module Wombat
    class Client < ClientBase

      def self.push_batches(object)
        self.get_items(object) do |item_json|
          push item_json
        end
      end

      def self.push(json_payload)
        options = {
            :headers => {
              :'Content-Type' => 'application/json',
              :'X-Hub-Store' => Spree::Wombat::Config[:connection_id],
              :'X-Hub-Access-Token' => Spree::Wombat::Config[:connection_token],
              :'X-Hub-Timestamp' => Time.now.utc.to_i.to_s
          },
          :body => json_payload
        }
        res = HTTParty.post(Spree::Wombat::Config[:push_url], options=options)
        validate(res)
      end

      def self.validate(res)
        raise PushApiError, "Push not successful. Wombat returned response code #{res.code} and message: #{res.body}" if res.code != 202
      end
    end
  end
end

class PushApiError < StandardError; end
