require 'slack-ruby-client'
require 'yaml'
require File.expand_path(File.dirname(__FILE__) + '/common.rb')

conf = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))

Slack.configure do |config|
    config.token = conf["slack"]["drac"]["api_token"]
end

team_name = conf["slack"]["drac"]["team_name"]
response_type = conf["slack"]["drac"]["response_type"]

client = Slack::RealTime::Client.new

client = configure_client(client, team_name, response_type)

client.start!
