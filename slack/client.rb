require 'slack-ruby-client'
require 'yaml'
require 'parallel'

require File.expand_path(File.dirname(__FILE__) + '/common.rb')

config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))

PLATFORM = "slack"

Parallel.each(config[PLATFORM], in_process: config[PLATFORM].length) do |conf|

  Slack.configure do |c|
    c.token = conf["api_token"]
  end

  client = Slack::RealTime::Client.new

  client = configure_client(client, PLATFORM, conf["team"], conf["response_type"])

  client.start!

end

