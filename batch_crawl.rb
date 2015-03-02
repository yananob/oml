#!/usr/local/bin/ruby

require 'time'
require 'class/common'
require 'class/mailer'
require 'class/mydb'
require 'class/oml_log'
require 'class/page'

begin
	page = Page.new
	cnt = 0
	my = MyDB.new
	mail = Mailer.new
#	res = my.query("SET NAMES utf8", [])
	day = Time.now.strftime("%a")		# 今日の曜日
	
	# 今日送る予定なのに、今日更新してない人、を取得
	# 曜日は、略称を部分一致検索する
	sql = "select * " +
	      "  from oml_user_m " +
#	      " where send_day like ? " +		# → 毎日実行するように変更
	      " order by send_time " +				# 送信が早い人から処理
	      " limit 0, 10 "						# ※10件ずつ処理
	res = my.query(sql, ["%" + day + "%"])
	dump("found " + res.num_rows().to_s + " users")
	res.each do |row|
		# 今日未処理のユーザを取得
		sql_ml = "select * " +
		         "  from oml_user_ml_m " +
		         " where mail = ? " +
		         "   and (crawled is null " +
		         "     or date_format(crawled, '%Y-%m-%d') <> curdate()) "
		res_ml = my.query(sql_ml, [row[0]])
		
		res_ml.each do |row_ml|
			oml_acc = OmlAcc.new(row_ml[0], row_ml[1])
			log = OmlLog.new(oml_acc)
			
			# 巡回にtry
			begin
				log.crawl
			rescue => exp
				# ユーザにメール送信
				subject = "[oml] 巡回エラー"
				body = "図書館サイトの巡回に失敗しました。\n" +
				       "  図書館カード番号: " + oml_acc.oml_id + "\n" +
				       "登録内容に間違いがないか、確認をお願いします。\n" +
				       "\n" + 
				       "http://oml.nicher.jp/\n"
				mail.send(subject, MAIL_ADMIN, body.toutf8, [])
				
				dump("crawl failed for " + oml_acc.mail + "[" + oml_acc.seq + "]")
				
				next		# 次のアカウントを処理
			ensure
			end
			
			cnt += 1
			dump("crawled for " + oml_acc.mail + "[" + oml_acc.seq + "]")
		end
	end
	
	dump("crawled " + cnt.to_s + " accounts")
	
rescue => exp
#	page.show_error(exp)
	# 管理者にメール送信
	subject = "[oml] 巡回エラー"
	body = "図書館サイトの巡回に失敗しました。\n" +
	       "\n" + 
	       exp.message + "\n\n" +
	       exp.backtrace.join("\n")
	mail.send(subject, MAIL_ADMIN, body.toutf8, [])
	
else
ensure
end
