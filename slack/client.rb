require 'slack-ruby-client'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))

PLATFORM = "slack"

class SlackClient

  def initialize(conf)
    @config = conf
    @processer = MessageProcesser.new(PLATFORM, conf["team"], conf["response_type"])
    self.start
  end

  def start
    Parallel.each(@config[PLATFORM], in_process: @config[PLATFORM].length) do |conf|
      Slack.configure do |c|
        c.token = conf["api_token"]
      end
      client = Slack::RealTime::Client.new
      client = self.configure_client(client)
      client.start!
    end
  end

  def configure_client(client)
    client.on :hello do
      puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}'"
    end
    client.on :message do |data|
      response = @processer.get_response(data.text)
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

end

SlackClient.new(config)

