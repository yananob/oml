#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/user'
require 'class/page'
require 'class/exp_input'

cgi = CGI.new
page = Page.new
begin
	page.set_header(cgi)
	
	cmd = cgi['cmd']
	cmd_next = "update"		# デフォルト値
	
	session = check_login(cgi)
	
	if (cmd == "new")
		# データを空で表示
		oml_acc = OmlAcc.new(session['mail'], "")
		cmd_next = "add"	# ここだけ変更
		page.show("edit_oml_acc", "カード新規登録", true, binding)
		
		exit
	elsif (cmd == "add")
		oml_acc = OmlAcc.new(session['mail'], "")
		oml_acc.set_cgi_param(cgi)
		oml_acc.add
		
		page.redirect("menu.rb")
	end
	
	case cmd
	when "edit"
		oml_acc = OmlAcc.new(session['mail'], cgi["seq"])
		
		page.show("edit_oml_acc", "カード編集", true, binding)
		exit
	
	when "update"
		oml_acc = OmlAcc.new(session['mail'], cgi["seq"])
		oml_acc.set_cgi_param(cgi)
		oml_acc.update
	
	when "remove"
		oml_acc = OmlAcc.new(session['mail'], cgi["seq"])
		oml_acc.remove
		
	else
		raise "unknown cmd: " + cmd
	end
	
	# メニューへ戻る
	page.redirect("menu.rb")
	
rescue => exp
	page.show_error(exp)
ensure
	session.close if session
end
