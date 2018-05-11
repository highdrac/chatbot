require 'slack-ruby-client'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"

PLATFORM = "slack"

class SlackClient

  def initialize(config)
    @processer = MessageProcesser.new(PLATFORM, config["team"], config["response_type"])
    Slack.configure do |c|
      c.token = config["api_token"]
    end
    client = Slack::RealTime::Client.new
    client = self.configure_client(client)
    client.start!
  end

  def configure_client(client)
    client.on :hello do
      puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}'"
    end
    client.on :message do |data|
      response = @processer.get_response(data.text)
      if response.notice
        username = (data.user == "USLACKBOT") ? "<!channel>" : "<@#{data.user}>"
        response.text = (username << " " << response.text)
      end
      client.message channel: data.channel, text: response.text unless response.text.empty?
    end
    client.on :close do |_data|
      puts "Client is about to disconnect"
    end
    client.on :closed do |_data|
      puts "Client has disconnected successfully!"
    end
    return client
  end

end

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
config = config[PLATFORM]

Parallel.each(config, in_process: config.length) do |config|
  SlackClient.new(config)
end

