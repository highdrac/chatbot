class Omikuji
  def initialize(config)
    @config = config["omikuji"]
  end

  def draw(type)
    @templates = @config[type]["templates"]
    if (!@templates)
      response_data.error_message = "そのおみくじは存在しません。"
      return response_data
    end
    response_data = ResponseData.new
    response_data.templates = @templates
    response_data.data = "dummy"
    return response_data
  end
end


