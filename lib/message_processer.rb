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

    # Google Search
    if /^g(?:oogle)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "", response_type: @response_type }
      random = (r == "r")
      gcs = GoogleCustomSearch.new(params)
      return gcs.search(random)

    # Google Search (image)
    elsif /^i(?:mage)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "", response_type: @response_type, search_type: "image" }
      random = (r == "r")
      gcs = GoogleCustomSearch.new(params)
      return gcs.search(random)

    # Google Search (Wikipedia)
    elsif /^wiki(?:pedia)?[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "ja.wikipedia.org", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (uncyclopedia)
    elsif /^uncy(?:clopedia)?[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "ansaikuropedia.org", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (youtube)
    elsif /^(?:you)?tube[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "youtube.com", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (niconico)
    elsif /^nico(?:nico)?[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "www.nicovideo.jp", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (nicodic)
    elsif /^n(?:ico)?dic[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "dic.nicovideo.jp", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (pixivdic)
    elsif /^p(?:ixiv)?dic[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "dic.pixiv.net", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # Google Search (mhw)
    elsif /^mhw[\s　]+?(?<keyword>.+)$/ =~ text
      params = { keyword: keyword, site: "mhwg.org", response_type: @response_type }
      gcs = GoogleCustomSearch.new(params)
      return gcs.search

    # tenki.jp
    elsif /^(tenki|weather|天気)[\s　]+?(?<area>.+)$/ =~ text
      params = { area: area }
      tj = TenkiJp.new(params)
      return tj.search

    end
  
  end

end

