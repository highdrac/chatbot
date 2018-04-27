require "spec_helper"
require "message_processer"

describe MessageProcesser do

  platform = "slack"
  team = "test"
  response_type = "default"

  it "init" do
    processer = MessageProcesser.new(platform, team, response_type)
    expect(processer.platform).to eq platform
    expect(processer.team).to eq team
    expect(processer.response_type).to eq response_type
  end

end
