require 'nokogiri'
require 'uri'
require 'open-uri'
require 'erb'
require 'yaml'


class TenkiJp

  SITE = "https://tenki.jp"
  SEARCH_URI = SITE + "/search"
  SEARCH_DETAIL_URL_XPATH = '//p[@class="search-entry-data"][1]/a'
  DETAIL_TITLE_XPATH = '//h2'
  DETAIL_TODAY_XPATH = '//section[@class="today-weather"]'
  DETAIL_TOMORROW_XPATH = '//section[@class="tomorrow-weather"]'
  DETAIL_WEATHER_XPATH = '//p[@class="weather-telop"]'
  DETAIL_HIGHTEMP_XPATH = '//dd[@class="high-temp temp"]'
  DETAIL_HIGHTEMPDIFF_XPATH = '//dd[@class="high-temp tempdiff"]'
  DETAIL_LOWTEMP_XPATH = '//dd[@class="low-temp temp"]'
  DETAIL_LOWTEMPDIFF_XPATH = '//dd[@class="low-temp tempdiff"]'
  DETAIL_RAIN_PROBABILITY_XPATH = '//tr[@class="rain-probability"]/td'

  RAIN_PROBABILITY_TERMS = 5
  RAIN_PROBABILITY_THRESHOLD = 30

  def initialize(response_type: "default")

    config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config.yml"))
    config = config["lib"]["tenki_jp"]

    @response_type = response_type
    @templates = config["templates"][@response_type]

  end

  def search(area: "東京都")

    # エリアのURI特定のため、検索してエリアのURIを取得する
    search_uri = URI.escape(SEARCH_URI + "/?keyword=" + area)
    detail_uri = ""
    response = Response.new

    begin

      doc = Nokogiri::HTML(open(search_uri))
      nodes = doc.xpath(SEARCH_DETAIL_URL_XPATH)
      detail_uri = URI.escape(SITE + nodes.first["href"])

    rescue => e

      p e
      response.text = "エラー：エリアが見つかりませんでした。"
      return response

    end

    begin

      doc = Nokogiri::HTML(open(detail_uri))
      title = doc.xpath(DETAIL_TITLE_XPATH).first.text
      area_name ||= area_name = $1 if title.match(/^(.+)の天気/)
      days = [
        { label: "今日", xpath: DETAIL_TODAY_XPATH },
        { label: "明日", xpath: DETAIL_TOMORROW_XPATH }
      ]

      text = ""
      rains = false
      days.each do |day|

        date = day[:label]
        weather = doc.xpath(day[:xpath] + DETAIL_WEATHER_XPATH).first.text
        hightemp = doc.xpath(day[:xpath] + DETAIL_HIGHTEMP_XPATH).first.text
        hightempdiff = doc.xpath(day[:xpath] + DETAIL_HIGHTEMPDIFF_XPATH).first.text
        lowtemp = doc.xpath(day[:xpath] + DETAIL_LOWTEMP_XPATH).text
        lowtempdiff = doc.xpath(day[:xpath] + DETAIL_LOWTEMPDIFF_XPATH).first.text
        rain_probability = []
        doc.xpath(day[:xpath] + DETAIL_RAIN_PROBABILITY_XPATH).each do |node|
          rain_probability.push(node.text)
        end
        rains = rains?(rain_probability)
        text << ERB.new(@templates["response"]).result(binding) << "\n"
      end
      if rains
        text = (@templates["rains"] << "\n") + text
        response.notice = true
      end
      response.text = text

    rescue => e

      p e
      response.text = "エラー：指定エリア情報の取得に失敗しました。"
      return response

    end

    return response

  end

  def rains?(probability)

    # 24-30h分を通知対象にカウントする
    cnt = 0
    probability.each do |prob|
      next if /^(\d+)/ !~ prob || cnt >= RAIN_PROBABILITY_TERMS
      cnt += 1
      return true if prob.to_i >= RAIN_PROBABILITY_THRESHOLD
    end
    return false

  end

end

