require 'discordrb'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"

PLATFORM = "discord"

class DiscordClient

  def initialize(conf)
    @processer = MessageProcesser.new(PLATFORM, conf["team"], conf["response_type"])
    client = Discordrb::Bot.new(client_id: conf["client_id"], token: conf["token"])
    client = self.configure_client(client)
    client.run
  end

  def configure_client(client)
    client.message do |event|
      p event
      response = @processer.get_response(event.message.content)
      event.respond response.text unless resnpose.text.empty?
    end
    return client
  end

end

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
config = config[PLATFORM]

DiscordClient.new(config)
