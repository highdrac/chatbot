require 'nokogiri'
require 'uri'
require 'open-uri'
require 'erb'

SITE = "https://tenki.jp"
SEARCH_URI = SITE + "/search"
SEARCH_XPATH = '//p[@class="search-entry-data"][1]/a'
DETAIL_TITLE_XPATH = '//h2'
DETAIL_TODAY_XPATH = '//section[@class="today-weather"]'
DETAIL_TOMORROW_XPATH = '//section[@class="tomorrow-weather"]'
DETAIL_WEATHER_XPATH = '//p[@class="weather-telop"]'
DETAIL_HIGHTEMP_XPATH = '//dd[@class="high-temp temp"]'
DETAIL_HIGHTEMPDIFF_XPATH = '//dd[@class="high-temp tempdiff"]'
DETAIL_LOWTEMP_XPATH = '//dd[@class="low-temp temp"]'
DETAIL_LOWTEMPDIFF_XPATH = '//dd[@class="low-temp tempdiff"]'
DETAIL_RAIN_PROBABILITY_XPATH = '//tr[@class="rain-probability"]/td'

RESPONSE_TEMPLATE = <<'EOS'
<%= date %>の<%= area_name %>の天気：<%= weather %>
<%= hightemp %><%= hightempdiff %>/<%= lowtemp %><%= lowtempdiff %>
<%= rain_probability.join('/') %>
EOS

class TenkiJp

  def initialize(area: "東京都")

    @area = area

  end

  def search

    # エリアのURI特定のため、検索してエリアのURIを取得する
    search_uri = URI.escape(SEARCH_URI + "/?keyword=" + @area)
    detail_uri = ""

    begin

      doc = Nokogiri::HTML(open(search_uri))
      nodes = doc.xpath(SEARCH_XPATH)
      detail_uri = URI.escape(SITE + nodes.first["href"])

    rescue => e

      return "エラー：エリアが見つかりませんでした。"

    end

    begin

      doc = Nokogiri::HTML(open(detail_uri))
      title = doc.xpath(DETAIL_TITLE_XPATH).first.text
      area_name = ""
      if /^(.+)の天気/ =~ title
        area_name = $1
      end
      days = [
        { label: "今日", xpath: DETAIL_TODAY_XPATH },
        { label: "明日", xpath: DETAIL_TOMORROW_XPATH }
      ]

      response = ""
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
        response += ERB.new(RESPONSE_TEMPLATE).result(binding)
      end

    rescue => e

      return "エラー：指定エリア情報の取得に失敗しました。"

    end

    return response

  end

end

