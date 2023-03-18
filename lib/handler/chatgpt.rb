require 'openai'
require 'json'

require File.expand_path(File.dirname(__FILE__)) + "/../redis_wrapper.rb"

class ChatGPT
  REDIS_KEY_PREFIX = "chatgpt_"
  SUMMARY_MAX_LENGTH = 100

  def initialize(config)
    config = config["chatgpt"]
    @templates = config["templates"]
    @client = OpenAI::Client.new(access_token: config["openai_api_key"])
    @talk_id = Hash.new(1)
  end

  def chat(message, channel)
    @redis = get_redis_client(channel)
    messages = load_history(@talk_id[channel])
    messages.push({role: "user", content: message})
    params = {
      model: "gpt-3.5-turbo",
      messages: messages,
    }
    begin
      response = @client.chat(parameters: params)
      response = response.dig("choices", 0, "message", "content")
      messages.push({role: "assistant", content: response})
      save_history(@talk_id[channel], messages)
      return get_response_data(response)
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      response_data.error_message = "エラーが発生しました。:" + e.message
    end
  end

  def system(message, channel)
    @redis = get_redis_client(channel)
    messages = load_history(@talk_id[channel])
    if messages.empty? || messages[0]["role"] != "system"
      messages.unshift({role: "system", content: message})
    else
      messages[0] = {role: "system", content: message}
    end
    save_history(@talk_id[channel], messages)
    return get_response_data("set system: " + @talk_id[channel].to_s)
  end

  def list(channel)
    @redis = get_redis_client(channel)
    histories = @redis.keys.map { |element| element.slice((get_prefix(channel).size)..-1) }
    return get_response_data(histories.to_s)
  end

  def detail(id, channel)
    @redis = get_redis_client(channel)
    histories = load_history(id)
    summary = []
    histories.each do |h|
      summary.push({role: h["role"], content: h["content"][0..SUMMARY_MAX_LENGTH]})
    end
    return get_response_data(summary.to_s)
  end

  def set_talk_id(id, channel)
    @talk_id[channel] = id.to_i
    return get_response_data("set talk id: " + @talk_id[channel].to_s)
  end

  def delete(id, channel)
    @redis = get_redis_client(channel)
    id = id.to_i
    @redis.del(id.to_s)
    @talk_id[channel] = 1
    return get_response_data("deleted id:" + id.to_s)
  end

  def clear(channel)
    @redis = get_redis_client(channel)
    @redis.keys.each do |key|
      @redis.del(key.slice((get_prefix(channel).size)..-1))
    end
    @talk_id[channel] = 1
    return get_response_data("cleared")
  end

  private

  def get_redis_client(channel)
    return RedisWrapper.new(get_prefix(channel))
  end

  def get_prefix(channel)
    return REDIS_KEY_PREFIX + channel.to_s + "_"
  end

  def get_response_data(response)
    response_data = ResponseData.new
    response_data.templates = @templates
    data = {}
    data[:text] = response
    response_data.data = data
    return response_data
  end

  def load_history(id)
    content = @redis.get(id.to_s)
    return [] if !content
    return JSON.parse(content)["history"]
  end

  def save_history(id, messages)
    content = {id: id, history: messages}.to_json
    @redis.set(id.to_s, content)
  end

end
