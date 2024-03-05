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

- 以下のコマンドを実行
```
./test_wptools.sh -l # 起動スクリプトを使う場合
```

### バズった記事の表示

- DBから取得したページ一覧とGoogleAnalyticsのCSVデータを突き合わせる
- Googleアナリスティックスで「行動 > サイトコンテンツ > すべてのページ」を開く。
 -期間を月単位で指定して表示する行数を5000に。CSV形式でエクスポートを実行。
- 以下のコマンドで実行
```
./test_wptools.sh -b data/Analytics_sablog_20200201-20200229.csv
```
- 結果をGoogleスプレッドシートに貼り付け。貼り付けたあと右下のメニューから列を選択すればCSV形式になる。


## ライセンス

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)
