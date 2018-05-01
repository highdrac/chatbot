require File.expand_path(File.dirname(__FILE__)) + "/google_custom_search.rb"
require File.expand_path(File.dirname(__FILE__)) + "/tenki_jp.rb"

class MessageProcesser

  attr_reader :platform, :team, :response_type

  def initialize(platform, team, response_type)
    @platform = platform
    @team = team
    @response_type = response_type
    @gcs = GoogleCustomSearch.new({ response_type: @response_type })
  end

  def get_response(text)
    response = ""

    case text
    # Google Search
    when /^g(?:oogle)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, random: true)

    # Google Search (image)
    when /^i(?:mage)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, search_type: "image", random: true)

    # Google Search (Wikipedia)
    when /^wiki(?:pedia)?[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "ja.wikipedia.org")

    # Google Search (uncyclopedia)
    when /^uncy(?:clopedia)?[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "ansaikuropedia.org")

    # Google Search (youtube)
    when /^(?:you)?tube[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "youtube.com")

    # Google Search (niconico)
    when /^nico(?:nico)?[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "www.nicovideo.jp")

    # Google Search (nicodic)
    when /^n(?:ico)?dic[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "dic.nicovideo.jp")

    # Google Search (pixivdic)
    when /^p(?:ixiv)?dic[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "dic.pixiv.net")

    # Google Search (mhw)
    when /^mhw[\s　]+?(?<keyword>.+)$/ 
      return @gcs.search(keyword, site: "mhwg.org")

    # tenki.jp
    when /^(tenki|weather|天気)[\s　]+?(?<area>.+)$/ 
      tj = TenkiJp.new({ area: area })
      return tj.search

    end
  
  end

end

