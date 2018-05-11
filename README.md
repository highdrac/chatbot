# chatbot

個人的に使用しているchatbot。  
SlackとDiscordに対応。  

## 動作環境↲

Ruby 2.5  
  
Discord側はlibsodium-devを入れておく。  

## デプロイ(未検証)

```
$ git clone git@github.com:highdrac/chatbot.git
$ bundle install
$ nohup bundle exec ruby ./slack/client.rb &
$ nohup bundle exec ruby ./discord/client.rb &
```

## help

()内は省略可

### Google Custom Search

g(oogle)(r) KEYWORD: Google検索(r: ランダム、デフォルトはoff)  
i(mage)(r) KEYWORD: Google画像検索(r: ランダム、デフォルトはoff)  
wiki(pedia) KEYWORD: Google検索(対象サイト: ja.wikipedia.org)  
uncy(clopedia) KEYWORD: Google検索(対象サイト: ansaikuropedia.org)  
(you)tube KEYWORD: Google検索(対象サイト: youtube.com)  
nico(nico) KEYWORD: Google検索(対象サイト: www.nicovideo.jp)  
n(ico)dic KEYWORD: Google検索(対象サイト: dic.pixiv.net)  
p(ixiv)dic KEYWORD: Google検索(対象サイト: dic.pixiv.net)  
mhw KEYWORD: Google検索(対象サイト: mhwg.org)  

### tenki.jp

{tenki|weather|天気] エリア名: 今日明日の天気予報  
エリア名は自治体名で記載する必要あり。できれば市もしくは区あたり(東京 だと誤爆したりします)

### NAVITIME

{route|乗換}(1-4) FROM(から)TO (YYYYMMDD) (HHMM)(発|着|始発|終電): 乗換案内  
表示候補数を数値で指定する。デフォルトは1。始発/終電のときは自動で1になる。  
日付/時間のデフォルトは現在日時。  
種別のデフォルトは発。  

## ToDo↲

ダイス機能  
辞書機能  

