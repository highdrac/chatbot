require 'yaml'
require 'google/apis/customsearch_v1'
require 'erb'

class GoogleCustomSearch

  def initialize(keyword:, site: "", response_type: "default", search_type: "text")

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
    config = config["lib"]["google_custom_search"]

    @keyword = keyword
    @site = site
    @search_type = (search_type == "image") ? "image" : nil
    @api_key = config["api_key"]
    @search_engine_id = config["search_engine_id"]
    @template = config["template"][search_type][response_type]

    @customsearch = Google::Apis::CustomsearchV1::CustomsearchService.new
    @customsearch.key = @api_key

  end

  def search(random = false)

    list = @customsearch.list_cses(@keyword, cx: @search_engine_id, site_search: @site, search_type: @search_type)
    index = random ? rand(10) : 0
    data = list.items[index]
    return ERB.new(@template).result(binding)

  end

end

