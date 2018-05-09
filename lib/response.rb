class Response
  attr_accessor :text, :notice

  def initialize(text: "", notice: false)
    @text = text
    @notice = notice
  end
end
