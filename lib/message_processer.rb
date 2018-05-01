require File.expand_path(File.dirname(__FILE__)) + "/google_custom_search.rb"
require File.expand_path(File.dirname(__FILE__)) + "/tenki_jp.rb"

class MessageProcesser

  attr_reader :platform, :team, :response_type

  def initialize(platform, team, response_type)
    @platform = platform
    @team = team
    @response_type = response_type
  end

  def get_response(text)
    response = ""
    params = { keyword: keyword, response_type: @response_type }

    case text
    # Google Search
    when /^g(?:oogle)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "" }
      random = (r == "r")
      gcs = GoogleCustomSearch.new(params)
      return gcs.search(random)

    # Google Search (image)
    when /^i(?:mage)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "", search_type: "image" }
      random = (r == "r")
      gcs = GoogleCustomSearch.new(params)
      return gcs.search(random)

    # Google Search (Wikipedia)
    when /^wiki(?:pedia)?[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "ja.wikipedia.org" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (uncyclopedia)
    when /^uncy(?:clopedia)?[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "ansaikuropedia.org" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (youtube)
    when /^(?:you)?tube[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "youtube.com" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (niconico)
    when /^nico(?:nico)?[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "www.nicovideo.jp" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (nicodic)
    when /^n(?:ico)?dic[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "dic.nicovideo.jp" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (pixivdic)
    when /^p(?:ixiv)?dic[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "dic.pixiv.net" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (mhw)
    when /^mhw[\s　]+?(?<keyword>.+)$/ 
      params.merge{ site: "mhwg.org" }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # tenki.jp
    when /^(tenki|weather|天気)[\s　]+?(?<area>.+)$/ 
      tj = TenkiJp.new({ area: area })
      return tj.search

    end
  
  end

end

