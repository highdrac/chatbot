require 'slack-ruby-client'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_formatter.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/platform.rb"

PLATFORM = Platform::SLACK

class SlackClient

  def initialize(config)
    @processer = MessageProcesser.new(platform: PLATFORM)
    @formatter = MessageFormatter.new(platform: PLATFORM)
    @config = config
    @response_type = @config["response_type"]
    Slack.configure do |c|
      c.token = @config["api_token"]
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
      response_data = @processer.get_response_data(channel: data.channel, text: data.text, config: @config)
      if response_data.error_message
        client.message channel: data.channel, text: response_data.error_message
      elsif response_data.data
        response = @formatter.get_response(response_data: response_data, response_type: @response_type)
        if response_data.notice
          username = (data.user == "USLACKBOT") ? "<!channel>" : "<@#{data.user}>"
          response = username << " " << response
        end
        client.message channel: data.channel, text: response unless response.empty?
      end
    end
    client.on :close do |_data|
      puts "Client is about to disconnect"
    end
    client.on :closed do |_data|
      puts "Client has disconnected successfully!"
      client.start!
    end
    return client
  end

end

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
config = config[PLATFORM]

Parallel.each(config, in_process: config.length) do |_channel, config|
  begin
    SlackClient.new(config)
  rescue => e
    puts e.backtrace
    exit
  end
end

