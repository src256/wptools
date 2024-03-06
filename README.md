wptools
==============

WordPressのテーブルを扱うスクリプト

## 実行環境

- macOS
- Ruby
- MySQL

## インストール方法

適当なフォルダに展開してbuild.shを実行。

## 使用方法

### 記事一覧の表示

- 「--command=list」を指定すると記事一覧を表示する。「-l 10」で10件表示する。
```
./run_wptools.sh --command=list -l 10 config/config_sample.yml
```

### バズった記事の表示

- DBから取得したページ一覧とGoogleAnalyticsのCSVデータを突き合わせる
- Googleアナリスティックスで「行動 > サイトコンテンツ > すべてのページ」を開く。
- 期間を月単位で指定して表示する行数を5000に。CSV形式でエクスポートを実行。
- 「--command=buzz」を指定するとバズった記事を表示する。「-b」でGoogleAnalyticsのCSVデータを指定する。
```
./run_wptools.sh --command=buzz data/Analytics_20200201-20200229.csv
```
- 結果をGoogleスプレッドシートに貼り付け。貼り付けたあと右下のメニューから列を選択すればCSV形式になる。

### DBを操作する

- 以下のようなrbスクリプト(test.rb)を作成。
```ruby
require "wptools"

STDOUT.sync = true
Wptools::Command.run(ARGV)
Wptools::WpPost.published_posts.order(post_date: "DESC").limit(100).each do | post|
  print "#{post.id} #{post.post_type} #{post.post_date_str} #{post.post_title} #{post.post_name}\n"
end

```
- これを「--command=none」で呼び出す。
```
ruby test.rb --command=none config/config_sample.yml
```


## ライセンス

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)
