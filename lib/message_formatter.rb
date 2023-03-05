require 'erb'

require File.expand_path(File.dirname(__FILE__)) + "/emoji.rb"

class MessageFormatter

  def initialize(platform:)
    @platform = platform
  end

  def get_response(response_data:, response_type:)
    begin
      data = response_data.data
      template = response_data.templates[response_type]
      if template.instance_of?(Array)
        template = template[rand(template.size)]
      end
      return ERB.new(template).result(binding)

    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      return "テンプレートエラーが発生しました。"
    end
  end
end

