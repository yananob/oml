#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/oml_log'
require 'class/user'
require 'class/page'
require 'class/exp_other'

begin
	cgi = CGI.new
	page = Page.new
	
	page.set_header(cgi)
	
	session = check_login(cgi)
	seq = cgi['seq']
	
	user = User.new(session['mail'])
	oml_acc = user.oml_acc[seq]
	log = OmlLog.new(oml_acc)
	
	cmd = cgi['cmd']
	case cmd
	when "show"
	
	when "refresh"
		log.crawl
	
	when "cancel_resv"
		log.cancel_resv(cgi['no'])
	
	when "extend"
		log.extend(cgi['no'])
	
	else
		raise OtherException, "unknown cmd: " + cmd
	end
	
	#page.show("disp_log", "ログ表示", true, binding)
	page.show("menu", "メニュー表示", true, binding)
	
rescue => exp
	page.show_error(exp)
ensure
	session.close if session
end
