#!/usr/local/bin/ruby

require 'time'
require 'class/common'
require 'class/mailer'
require 'class/mydb'
require 'class/user'
require 'class/page'
require 'class/oml_log'
require 'class/oml_acc'

begin
	page = Page.new
	cnt = 0
	my = MyDB.new
#	res = my.query("SET NAMES utf8", [])
	day = Time.now.strftime("%a")		# 今日の曜日
	
	# *** ログのメール送信
	mail = Mailer.new
	# 今日・今の時間に送る人を取得
	sql = "select mail " +
	      "  from oml_user_m " +
	      " where send_day like ? " +
	      "   and send_time = ? " +
	      " order by mail "
	# 曜日は、略称を部分一致検索する
	res = my.query(sql, ["%" + day + "%", Time.now.hour.to_s])
	dump("found " + res.num_rows().to_s + " users")
	res.each do |row|
		user = User.new(row[0])
#		user.oml_acc.each_pair do |seq, oml_acc|
#			log = OmlLog.new(oml_acc)
#			
#			# メール送信用ファイル：未使用？
#			css = File.read("css/style.css")
#			
#			buf_send = page.erb_result("batch_send", binding)
#			f = open(log.file_path_send, "w")
#			f.write(buf_send)
#			f.close
#			
#			subject = "[oml] 予約・貸出図書レポート <" + oml_acc.memo + ">"
#			#body = "アカウント[" + oml_acc.memo + "](" + oml_acc.oml_id + ")の予約・貸し出し状況です。"
#			body = " "
#			mail.send(subject, user.mail, body.toutf8, log.file_path_send)
#			print "sent to " + user.mail + "\n"
#			cnt += 1
#		end
		buf_send = ""
		user.oml_acc.each_pair do |seq, oml_acc|
			log = OmlLog.new(oml_acc)
			
			# メール送信用ファイル：未使用？
			css = File.read("css/style.css")
			
			buf_send += page.erb_result("batch_send", binding) + "<hr>"
		end
		f = open(user.file_path_send, "w")
		f.write(buf_send)
		f.close
		
		subject = "[oml] 予約・貸出図書レポート"
		#body = "アカウント[" + oml_acc.memo + "](" + oml_acc.oml_id + ")の予約・貸し出し状況です。"
		body = " "
		mail.send(subject, user.mail, body.toutf8, user.file_path_send)
		print "sent to " + user.mail + "\n"
		cnt += 1
		
		# *** 返却期限の通知
		notice = Array.new
		user.oml_acc.each_pair do |seq, oml_acc|
			# 貸出中書籍それぞれの、返却期限をチェック
			log = OmlLog.new(oml_acc)
			log.books_rent.each_pair do |no, book|
#				# 返却期限の2日前か？ TODO: ユーザごとに設定できるように
				if (book.near_limit?)
					notice.push(book)
				end
			end
		end
		if (notice.length > 0)
			subject = "[oml] 返却期限レポート"
			body = "返却期限が 2 日以内に迫っている図書をお知らせします。\n\n"
			notice.each do |book|
				body += "・" + book.ret_limit.to_s + "まで: " + book.book_name + "\n\n"
			end
			mail.send(subject, user.mail, body.toutf8, [])
			print "sent to " + user.mail + "\n"
		end
		sql = "update oml_user_m set " +
		      "     limit_noticed = now() " + 
		      " where mail = ? "
		res = my.query(sql, [user.mail])
	end
	dump("sent " + cnt.to_s + " mails")
	
rescue => exp
	# 管理者にメール送信
	subject = "[oml] 送信エラー"
	body = "batch_sendに失敗しました。\n" +
	       "\n" + 
	       exp.message + "\n\n" +
	       exp.backtrace.join("\n")
	mail.send(subject, MAIL_ADMIN, body.toutf8, [])
	
ensure
end
