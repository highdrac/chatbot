require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_processer.rb"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/message_formatter.rb"

@processer = MessageProcesser.new(platform: "dummy")
@formatter = MessageFormatter.new(platform: "dummy")
# メッセージ入力
text = "omikuji g1"
response_data = @processer.get_response_data(channel:"dummy", text:text, config:"dummy")
p response_data
response_type = "default"
response = @formatter.get_response(response_data: response_data, response_type: response_type)
p response
