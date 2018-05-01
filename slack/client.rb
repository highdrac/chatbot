require 'slack-ruby-client'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"

PLATFORM = "slack"

class SlackClient

  def initialize(conf)
    @processer = MessageProcesser.new(PLATFORM, conf["team"], conf["response_type"])
    Slack.configure do |c|
      c.token = conf["api_token"]
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
      client.message channel: data.channel, text: response unless response.empty?
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

Parallel.each(config, in_process: config.length) do |conf|
  SlackClient.new(conf)
end

