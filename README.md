# FindHaiku4Mstdn
mastodon上で、俳句を検出するbotのプログラムです。日々のトゥートの中で思いがけず生まれた５７５に光を当てるべく開発されました。

## 使い方
1. mecabをなんとかして入れる
2. 以下を参考に`key.yml`という設定ファイルを作成し、どうにかして`base_url`と`access_token`を入手して記載する
```key.yml
base_url: theboss.tech
access_token: tx8j4j3yb5ibxuns6i3w73ndpffmg4c7jxcr7jr5psgn5de4a38k5d5jjc4tsir8
```
3. `bundle install`
4. `bundle exec ruby main.rb`
5.  ✌('ω'✌ )三✌('ω')✌三( ✌'ω')✌

## 現状の問題
- フォロー返し
  - 現在は手動で対応
- 拗音とか？
  - [r7kamura/ikku](https://github.com/r7kamura/ikku)に依存。
  - フォークして対応？
- 目標のトゥートの公開範囲に拘わらず未収載で返信する
  - [tootsuite/mastodon-api](https://github.com/tootsuite/mastodon-api)を使いこなせていない。トゥートの公開範囲を取れない。
- 反応しないトゥートの判断が雑
  - 自分のトゥートに反応して無限ループが発生するため、リプライをすべて除外している。

## その他
問題を発見した方は[@theoria@wug.fun](https://wug.fun/@theoria)や[@theoria@knzk.me](https://knzk.me/@theoria)、[@theoria@theboss.tech](https://theboss.tech/@theoria)、[@theoria@mstdn.jp](https://mstdn.jp/@theoria)、あるいは[Twitter](https://twitter.com/_theoria)に連絡していただけるとありがたいです。ここに[Issue](https://github.com/theoria24/FindHaiku4Mstdn/issues/new)を立てていただいても構いません。

プルリク歓迎です。
