class MessageProcesser

  attr_reader :platform, :team, :response_type

  def initialize(platform, team, response_type)
    @platform = platform
    @team = team
    @response_type = response_type
  end

  def get_response(text)

    return "test"

  end

end

