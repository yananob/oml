(旧)大阪市立図書館への便利アクセスツール
==============

## 概要
　大阪市立図書館旧Webサイト（2014年以前）の使い勝手を改善するために、大阪市立図書館に便利にアクセスするためのツールとして、2007年に構築しました。  

　当時不便だった点は、

- 予約中の図書や延長申請をするために、貸出カード番号とパスワードのほか、割り当てられたパスコードの入力してログインする必要があった。
- 家族の貸出カードを含めて複数のカードを保有している場合、各カードの情報を見るために、それぞれのカード番号でログインする必要があった。

といった点でした。  

これらを解決するために、

- ログインは、メールアドレスとパスワードで可能にする
- ログインユーザに対して、複数の貸出カード情報を登録可能にし、予約中図書や延長申請は複数のカードいずれに対しても行えるようにする

という改善を行い、便利に使っていました。  

当初は一般の方でも使えるよう、ユーザ登録ページ等も設けていましたが、諸事情により自分専用のサービスになっています。


## 動作環境URL　※現在は動作しません
- [ログインページ](http://nicher.s310.xrea.com/oml/)  
- [ヘルプ（画面イメージあり）](http://nicher.s310.xrea.com/oml/help.rb)

※大阪市立図書館Webサイトのリニューアル（2014年）によってページ構造が変わったため、現在は動作しません。リニューアルでも不便な点はまだ残っていますが、Webスクレイピングがうまく行かず、対応できていません。

## 使用技術等
- Ruby
- MySQL
