# chatbot

個人的に使用しているchatbot。  
SlackとDiscordに対応。  

## 動作環境

Ruby 2.5  
Redis 4.0  
  
Discord側はlibsodium-devを入れておく。  

## 使い方(未検証)

```
$ git clone git@github.com:highdrac/chatbot.git
$ bundle install
$ nohup bundle exec ruby ./slack/client.rb &
$ nohup bundle exec ruby ./discord/client.rb &
```

## ToDo

機能追加  

