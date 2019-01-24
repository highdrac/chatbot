require 'yaml'


class Omikuji

  def initialize

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../../config.yml"))
    config = config["lib"]["omikuji"]

    @templates = config["templates"]

  end

  def draw

    response_data = ResponseData.new
    response_data.templates = @templates
    response_data.data = "dummy"
    return response_data

  end

end


