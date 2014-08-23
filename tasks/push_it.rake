require 'spree/wombat'

namespace :wombat do
  desc 'Push batches'
  task :push_it => :environment do
    use_http_client = Spree::Wombat::Config[:mechanism] == 'http'
    if use_http_client && (Spree::Wombat::Config[:connection_token] == "YOUR TOKEN" || Spree::Wombat::Config[:connection_id] == "YOUR CONNECTION ID")
      abort("[ERROR] It looks like you did not add your credentails to config/intializers/wombat.rb, please add them and try again. Exiting now")
    end
    puts "\n\n"
    puts "Starting pushing objects"
    if use_http_client
      client = Spree::Wombat::Client.new
    else
      client = Spree::Wombat::MqClient.new
    end
    Spree::Wombat::Config[:push_objects].each do |object|
      client.push_batches(object)
      puts "Pushed #{object}"
    end
  end
end
