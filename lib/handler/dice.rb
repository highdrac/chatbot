class Dice

  MAX_NUM = 100
  MAX_SURFACES = 10000

  def initialize(config)
    @templates = config["dice"]["templates"]
  end

  def role(text)
    matches = []
    text.scan(/(\[(\d+)[Dd](\d+)([+-]\d+)?.*?\])/) do |whole, num, surface, correction|
      hash = {}
      hash[:whole] = whole
      hash[:num] = num.to_i
      hash[:surface] = surface.to_i
      hash[:correction] = correction
      matches.push(hash)
    end
    response_data = ResponseData.new
    response_data.templates = @templates
    data = {}
    begin
      matches.each do |hash|
        sum = 0
        result = []
          if hash[:num] == 0 || hash[:num] > MAX_NUM || hash[:surface] == 0 || hash[:surface] > MAX_SURFACES
          raise StandardError
        end
        hash[:num].times do
          outcome = rand(hash[:surface]) + 1
          sum += outcome
          result.push(outcome)
        end
        result = result.join(",")
        if hash[:correction]
          result += hash[:correction]
          sign = hash[:correction].slice!(0)
          value = hash[:correction].to_i
          sum = (sign == "-") ? sum - value : sum + value
        end
        result = sum.to_s
        text.sub!(Regexp.new(Regexp.escape(hash[:whole])), result)
      end
      data[:text] = text
      response_data.data = data
      return response_data
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      response_data.error_message = "エラーが発生しました。管理者にお知らせください。"
      return response_data
    end
  end
end

