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
	
	session = check_login(cgi)
	
	case cmd
	when "search"
		mecha = OmlMecha.new
		mecha.search(cgi['keyword'])
		
		
		★★★
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
