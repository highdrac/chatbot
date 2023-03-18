require 'nokogiri'
require 'uri'
require 'open-uri'

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

  def initialize(config)
    config = config["tenki_jp"]
    @templates = config["templates"]
  end

  def search(area: "東京都")
    # エリアのURI特定のため、検索してエリアのURIを取得する
    search_uri = SEARCH_URI + "/?" + URI.encode_www_form(keyword: area)
    detail_uri = ""
    response_data = ResponseData.new
    response_data.templates = @templates
    begin
      doc = Nokogiri::HTML(Net::HTTP.get(URI(search_uri)))
      nodes = doc.xpath(SEARCH_DETAIL_URL_XPATH)
      detail_uri = SITE + nodes.first["href"]
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      response_data.error_message = "エラー：エリアが見つかりませんでした。"
      return response_data
    end
    begin
      p detail_uri
      doc = Nokogiri::HTML(Net::HTTP.get(URI(detail_uri)))
      title = doc.xpath(DETAIL_TITLE_XPATH).first.text
      area_name ||= area_name = $1 if title.match(/^(.+)の天気/)
      days = [
        { label: "今日", xpath: DETAIL_TODAY_XPATH },
        { label: "明日", xpath: DETAIL_TOMORROW_XPATH }
      ]
      data = {}
      data[:area_name] = area_name
      data[:weather] = []
      probability = []
      days.each do |day|
        weather = {}
        weather[:date] = day[:label]
        weather[:weather] = doc.xpath(day[:xpath] + DETAIL_WEATHER_XPATH).first.text
        weather[:hightemp] = doc.xpath(day[:xpath] + DETAIL_HIGHTEMP_XPATH).first.text
        weather[:hightempdiff] = doc.xpath(day[:xpath] + DETAIL_HIGHTEMPDIFF_XPATH).first.text
        weather[:lowtemp] = doc.xpath(day[:xpath] + DETAIL_LOWTEMP_XPATH).text
        weather[:lowtempdiff] = doc.xpath(day[:xpath] + DETAIL_LOWTEMPDIFF_XPATH).first.text
        weather[:rain_probability] = []
        doc.xpath(day[:xpath] + DETAIL_RAIN_PROBABILITY_XPATH).each do |node|
          weather[:rain_probability].push(node.text)
          probability.push(node.text)
        end
        data[:weather].push weather
      end
      if data[:rains] = rains?(probability)
        response_data.notice = true
      end
      response_data.data = data
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      response_data.error_message = "エラー：指定エリア情報の取得に失敗しました。"
      return response_data
    end
    return response_data
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
