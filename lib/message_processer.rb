require File.expand_path(File.dirname(__FILE__)) + "/response_data.rb"

require File.expand_path(File.dirname(__FILE__)) + "/handler/chatgpt.rb"
require File.expand_path(File.dirname(__FILE__)) + "/handler/google_custom_search.rb"
require File.expand_path(File.dirname(__FILE__)) + "/handler/tenki_jp.rb"
require File.expand_path(File.dirname(__FILE__)) + "/handler/navitime.rb"
require File.expand_path(File.dirname(__FILE__)) + "/handler/dice.rb"
require File.expand_path(File.dirname(__FILE__)) + "/handler/omikuji.rb"

class MessageProcesser
  def initialize(platform:, config:)
    @platform = platform
    @gpt = ChatGPT.new(config)
    @gcs = GoogleCustomSearch.new(config)
    @tj = TenkiJp.new(config)
    @nt = Navitime.new(config)
    @dice = Dice.new(config)
    @omikuji = Omikuji.new(config)
  end

  def get_response_data(channel:, text:)
    return ResponseData.new if !text
    # Reminder機能から呼び出し可能にする
    text.gsub!(/^Reminder: (.+)\.\n?/, '\1')
    # ChatGPT list
    if /^gpt[\s　]+?list$/ =~ text
      return @gpt.list(channel)
    # ChatGPT detail
    elsif /^gpt[\s　]+?detail[\s　]+?(?<id>[\d]+)$/ =~ text
      return @gpt.detail(id, channel)
    # ChatGPT set current id
    elsif /^gpt[\s　]+?id[\s　]+?(?<id>[\d]+)$/ =~ text
      return @gpt.set_talk_id(id, channel)
    # ChatGPT delete
    elsif /^gpt[\s　]+?delete[\s　]+?(?<id>[\d]+)$/ =~ text
      return @gpt.delete(id, channel)
    # ChatGPT clear
    elsif /^gpt[\s　]+?clear$/ =~ text
      return @gpt.clear(channel)
    # ChatGPT
    elsif /^gpt[\s　]+?(?<message>.+)$/ =~ text
      return @gpt.chat(message, channel)
    # Google Search
    elsif /^g(oogle)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, random: !r.nil?)
    # Google Search (image)
    elsif /^i(mage)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, search_type: "image", random: !r.nil?)
    # Google Search (Wikipedia)
    elsif /^wiki(pedia)?[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "ja.wikipedia.org")
    # Google Search (uncyclopedia)
    elsif /^uncy(clopedia)?[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "ansaikuropedia.org")
    # Google Search (youtube)
    elsif /^(you)?tube[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "youtube.com")
    # Google Search (niconico)
    elsif /^nico(nico)?[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "www.nicovideo.jp")
    # Google Search (nicodic)
    elsif /^n(ico)?dic[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "dic.nicovideo.jp")
    # Google Search (pixivdic)
    elsif /^p(ixiv)?dic[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "dic.pixiv.net")
    # Google Search (mhw)
    elsif /^mhw[\s　]+?(?<keyword>.+)$/ =~ text
      return @gcs.search(keyword, site: "mhwg.org")
    # tenki.jp
    elsif /^(tenki|weather|天気)[\s　]+?(?<area>.+)$/ =~ text
      return @tj.search(area: area)
    # navitime
    elsif /^(route|乗換)(?<candidate>\d)?[\s　]+?(?<dep>[^\s　]+?)([\s　]+|から)(?<arr>[^\s　]+?)([\s　]+?(?<ymd>\d{8}))?([\s　]+?(?<hm>\d{4})?(?<basis>発|着|始発|終電)?)?$/ =~ text
      return @nt.search(dep: dep, arr: arr, ymd: ymd, hm: hm, basis: basis, candidate: candidate)
    # omikuji
    elsif /^omikuji[\s　]+?(?<type>.+)$/ =~ text
      return @omikuji.draw(type)
    # dice
    elsif /\[\d+[Dd]\d+([+-]\d+)?.*?\]/ =~ text
      return @dice.role(text)
    end

    return ResponseData.new

  end

end
