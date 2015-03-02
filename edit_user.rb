#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/user'
require 'class/page'
require 'class/exp_input'
require 'class/mailer'

def check_input(cgi, cmd, user)
	check_blank(cgi['mail'], "メールアドレス")
	if (cmd == "add")
		check_blank(cgi['pwd'], "パスワード")		# 必須でない
	end
	check_blank(cgi.params['send_day'].join(","), "メール送信曜日")		# 連結して、1つでも値があるか確認
	check_blank(cgi['send_time'], "メール送信時刻")
	
	# 新しく入力したメールアドレスが、既存でないか確認
	if (cmd == "add" || user.mail != cgi["mail"])
		dbuser = User.new(cgi['mail'])
		if (dbuser.is_exist)
			raise InputException, "既に登録されているメールアドレスです。"
		end
	end
end

cgi = CGI.new
page = Page.new
begin
	page.set_header(cgi)
	
	cmd = cgi['cmd']
	cmd_next = "update"		# デフォルト値
	
	if (cmd == "new")
		# userを空で表示
		user = User.new("")
		cmd_next = "add"	# ここだけ変更
		page.show("edit_user", "ユーザ新規登録", false, binding)
		
		exit
	elsif (cmd == "add")
		user = User.new("")
		check_input(cgi, cmd, user)
		user.add(cgi)
		
		# 登録通知
		subject = "[oml] New user has come."
		body = "新しいユーザが登録されました。\n" +
		       "  メールアドレス: " + cgi["mail"] + "\n" +
		       "\n" + 
		       "http://oml.nicher.jp/\n"
		mail = Mailer.new
		mail.send(subject, MAIL_ADMIN, body.toutf8, [])
		
		# 自動的にログイン
		page.redirect("menu.rb?cmd=login&mail=" + cgi["mail"] + "&pwd=" + cgi["pwd"])
	end
	
	session = check_login(cgi)
	case cmd
	when "edit"
		user = User.new(session['mail'])
	
	when "update"
		user = User.new(session['mail'])
		check_input(cgi, cmd, user)
		user.update(cgi)
		session['mail'] = user.mail
	
	when "remove"
		user = User.new(session['mail'])
		user.remove
		# userの値を初期値に設定して表示
		page.redirect("login.rb")
		
	else
		raise "unknown cmd: " + cmd
	end
	
	# userの値を初期値に設定して表示
	page.show("edit_user", "ユーザ編集", true, binding)
	
rescue => exp
	page.show_error(exp)
ensure
	session.close if session
end
