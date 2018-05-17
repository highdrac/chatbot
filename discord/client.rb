require 'discordrb'
require 'yaml'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_formatter.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/platform.rb"

PLATFORM = Platform::DISCORD

class DiscordClient

  def initialize(config)
    @processer = MessageProcesser.new(platform: PLATFORM)
    @formatter = MessageFormatter.new(platform: PLATFORM)
    client = Discordrb::Bot.new(client_id: config["client_id"], token: config["token"])
    client = self.configure_client(client)
    @config = config["servers"]
    client.run
  end

  def configure_client(client)
    client.message do |event|
      channel_id = event.message.channel.id
      response_data = @processer.get_response_data(channel: channel_id, text: event.message.content, config: @config[channel_id])
      if response_data.error_message
        event.respond response_data.error_message
      elsif response_data.data
        response_type = @config[channel_id]["response_type"]
        response = @formatter.get_response(response_data: response_data, response_type: response_type)
        event.respond response unless response.empty?
      end
    end
    return client
  end

end

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
config = config[PLATFORM]

DiscordClient.new(config)
