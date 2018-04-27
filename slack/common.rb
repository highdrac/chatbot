require File.expand_path(File.dirname(__FILE__)) + "/../lib/process.rb"

def configure_client(client, platform, team, response_type)

  client.on :hello do
    puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  end

  client.on :message do |data|
    response = process(data.text, platform, team, response_type)
    if response != ""
      client.message channel: data.channel, text: response
    end
  end

  client.on :close do |_data|
    puts "Client is about to disconnect"
  end

  client.on :closed do |_data|
    puts "Client has disconnected successfully!"
  end

  return client
end

