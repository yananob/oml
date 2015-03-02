#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/user'
require 'class/page'
require 'class/exp_other'
require 'class/oml_log'

begin
	cgi = CGI.new
	page = Page.new

	cmd = cgi['cmd']
	mail = cgi['mail']
	pwd = cgi['pwd']
	if (cmd == "try")
		mail = "oml_guest@nicher.jp"
		pwd = "oml_guest"
	end
	case cmd
	when "login", "try"
		# create new session
		session = CGI::Session.new(cgi, 'new_session' => true)
		session['mail'] = mail
		
		page.set_header(cgi)		# セッション保存用（sessionにセットした後に処理）
		
		# なぜかpage.set_headerの前にUser.newをすると、550エラーになる
		# ->	SQL文を出力してるから？
		#		ヘッダを手動で出力するの、やめたい
		# メモ：ログアウトしてもセッション自体は消えてないようで、一度セッション作成後、セッションが作られないコードになっても、テストしても分からない状態になる
		user = User.new(mail)
		user.cert(pwd)
		
	else
		page.set_header(cgi)
		
		session = check_login(cgi)
		user = User.new(session['mail'])
	end
	
	page.set_header(cgi)
	page.show("menu", "メニュー", true, binding)
	
rescue => exp
	page.show_error(exp)
ensure
	session.close if session
end
