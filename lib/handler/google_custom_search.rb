require 'yaml'
require 'google/apis/customsearch_v1'

class GoogleCustomSearch

  attr_reader :templates

  def initialize

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../../config.yml"))
    config = config["lib"]["google_custom_search"]

    @api_key = config["api_key"]
    @search_engine_id = config["search_engine_id"]
    @site = ""
    @search_type = "text"
    @templates = config["templates"]

    @customsearch = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    @customsearch.key = @api_key

  end

  def search(keyword, site: @site, search_type: @search_type, random: false)

    response_data = ResponseData.new

    begin
      # パラメータにはtextが渡せないので渡すときだけ削除
      st = (search_type == "text") ? nil : search_type
      list = @customsearch.list_cses(keyword, cx: @search_engine_id, site_search: site, search_type: st)
      index = random ? rand(10) : 0
      result = list.items[index]
      response_data.data = { title: result.title, link: result.link, search_type: search_type }
      response_data.templates = @templates

    rescue => e

      puts e.message
      puts e.backtrace.join("\n")
      response_data.error_message = "エラーが発生しました。"

    end

    return response_data

  end

end

