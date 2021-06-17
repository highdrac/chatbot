require 'yaml'


class Omikuji

  def initialize

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../../config.yml"))
    @config = config["lib"]["omikuji"]

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


