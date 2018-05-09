require 'yaml'
require 'google/apis/customsearch_v1'
require 'erb'

class GoogleCustomSearch

  def initialize(site: "", response_type: "default")

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
    config = config["lib"]["google_custom_search"]

    @api_key = config["api_key"]
    @search_engine_id = config["search_engine_id"]
    @site = ""
    @search_type = "text"
    @response_type = response_type
    @templates = config["templates"][@response_type]

    @customsearch = Google::Apis::CustomsearchV1::CustomsearchService.new
    @customsearch.key = @api_key

  end

  def search(keyword, site: @site, search_type: @search_type, random: false)

    # パラメータにはtextが渡せないので渡すときだけ削除
    st = (search_type == "text") ? nil : search_type
    list = @customsearch.list_cses(keyword, cx: @search_engine_id, site_search: site, search_type: st)
    index = random ? rand(10) : 0
    data = list.items[index]
    template = @templates[search_type]

    return Response.new(text: ERB.new(template).result(binding))

  end

end

