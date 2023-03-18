require 'discordrb'
require 'yaml'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_formatter.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/platform.rb"

PLATFORM = Platform::DISCORD
MESSAGE_MAX_LENGTH = 2000

class DiscordClient

  def initialize(platform_config, lib_config)
    @processer = MessageProcesser.new(platform: PLATFORM, config: lib_config)
    @formatter = MessageFormatter.new(platform: PLATFORM)
    client = Discordrb::Bot.new(client_id: platform_config["client_id"], token: platform_config["token"])
    client = self.configure_client(client)
    @config = platform_config["servers"]
    client.run
  end

  def configure_client(client)
    client.message do |event|
      channel_id = event.message.channel.id
      response_data = @processer.get_response_data(channel: channel_id, text: event.message.content)
      if response_data.error_message
        event.respond response_data.error_message
      elsif response_data.data
        response_type = @config[channel_id]["response_type"]
        response = @formatter.get_response(response_data: response_data, response_type: response_type)
        unless response.empty?
          p response[0..(MESSAGE_MAX_LENGTH - 1)]
          event.respond response[0...MESSAGE_MAX_LENGTH]
          response = response[MESSAGE_MAX_LENGTH..-1]
        end
      end
    end
    return client
  end

end

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
platform_config = config[PLATFORM]
lib_config = config["lib"]

DiscordClient.new(platform_config, lib_config)
