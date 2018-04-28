  require File.expand_path(File.dirname(__FILE__)) + "/google_custom_search.rb"

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
      end

      # Google Search (image)
      if /^i(?:mage)?(?<r>r)?[\s　]+?(?<keyword>.+)$/ =~ text
        params = { keyword: keyword, site: "", response_type: @response_type, search_type: "image" }
        random = (r == "r")
        gcs = GoogleCustomSearch.new(params)
        return gcs.search(random)
      end


  end

end

