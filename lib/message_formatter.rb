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
      return ERB.new(template).result(binding)
    rescue => e
      puts e.message
      puts e.stacktrace.join("\n")
      return "テンプレートエラーが発生しました。"
    end
  end
end
