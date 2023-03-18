require 'nokogiri'
require 'uri'
require 'net/http'
require 'active_support'
require 'active_support/core_ext'
require 'date'

class Navitime

  SITE = "https://www.navitime.co.jp"
  RESULT_URI = SITE + "/transfer/searchlist"

  SELECT_DEP_CODE_XPATH = '//select[@name="dep_code"]/option'
  SELECT_ARR_CODE_XPATH = '//select[@name="arr_code"]/option'
  RESULT_TITLE_XPATH = '//h1[@class="main_title"]'
  RESULT_SEARCH_TIME_XPATH = '//span[@class="search_time"]'
  RESULT_SUMMARY_XPATH = '//ol[contains(@class,"summary_list")]/li'
  RESULT_SUMMARY_TIME_XPATH = './/dt'
  RESULT_SUMMARY_CASH_XPATH = './/div[contains(@class,"cash")]'
  RESULT_SUMMARY_IC_XPATH = './/div[contains(@class,"ic")]'
  RESULT_SUMMARY_TRANSFER_XPATH = './/dd[contains(@class,"required_transfer")]/div[@class="text"]'
  RESULT_DETAIL_XPATH = '//input[@name="routeText"]'

  def initialize(config)
    config = config["navitime"]
    @templates = config["templates"]
  end

  def search(dep:, arr:, ymd:, hm:, basis:, candidate:)
    begin
      ymd ||= Date.today.strftime("%Y%m%d")
      ym = ymd[0..3] + "/" + ymd[4..5].sub(/^0/, "")
      d = ymd[6..7]
      hm ||= Time.now.strftime("%H%M")
      h = hm[0..1]
      m = hm[2..3]
      basis ||= "発"
      basis_hash = { "発" => 1, "着" => 0, "始発" => 4, "終電" => 3 }
      candidate ||= 1
      candidate = candidate.to_i
      candidate = 1 if basis_hash[basis] > 1
      query = { orvStationName: dep, dnvStationName: arr, month: ym, day: d, hour: h, minute: m, basis: basis_hash[basis] }
      result_uri = URI(RESULT_URI)
      result_uri.query = query.to_param
      response_data = ResponseData.new
      response_data.templates = @templates
      p result_uri
      doc = Nokogiri::HTML(Net::HTTP.get(result_uri))
      data = {}
      title = doc.xpath(RESULT_TITLE_XPATH).first.text.gsub(/[\s　]+/, " ").strip
      /出発\s(?<dep>.+)\s到着\s(?<arr>.+)/ =~ title
      data[:dep], data[:arr] = dep, arr
      data[:search_time] = doc.xpath(RESULT_SEARCH_TIME_XPATH).first.text
      data[:summary] = []
      doc.xpath(RESULT_SUMMARY_XPATH).each_with_index do |node, i|
        break if i >= candidate
        s = {}
        s[:number] = i + 1
        s[:time] = node.xpath(RESULT_SUMMARY_TIME_XPATH).first.text.gsub(/&nbsp;/, "")
        s[:fee] = node.xpath(RESULT_SUMMARY_CASH_XPATH).first.text
        s[:fee] << node.xpath(RESULT_SUMMARY_IC_XPATH).first.text if node.xpath(RESULT_SUMMARY_IC_XPATH)
        s[:transfer] = node.xpath(RESULT_SUMMARY_TRANSFER_XPATH).first.text.gsub(/[\s　]/, "")
        data[:summary].push s
      end
      data[:candidate] = []
      doc.xpath(RESULT_DETAIL_XPATH).each_with_index do |node, i|
        break if i >= candidate
        c = {}
        c[:number] = i + 1
        text = node["value"]
        text.gsub!(/<br>/, "\n")
        /(?<transfer>.+?)\n(?<time>.+?)\n(?<fee>.+?)\n/ =~ text
        c[:transfer], c[:time], c[:fee] = transfer, time, fee
        detail = ""
        text.scan(/(\d{2}:\d{2}発)　(\S+?)\n(.+?)\n(\d{2}:\d{2}着)　(\S+?)\n+/m).each_with_index do |line, j|
          if j == 0
            detail << line[0] << " " << line[1]
          else
            detail << " " << line[0]
          end
          detail << "\n" << line[2].split("\n")[0] << "\n" << line[3] << " " << line[4]
        end
        detail << "\n"
        c[:detail] = detail
        data[:candidate].push c
      end
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

