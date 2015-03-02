#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/page'

begin
	cgi = CGI.new
	page = Page.new
	
	page.set_header(cgi)
	
	cmd = cgi['cmd']
	case cmd
	when "logout"
		begin
			session = check_login(cgi)
			session['mail'] = nil
			session.delete if session
		rescue
		ensure
			session.close if session
		end
		
	else
	end
	
	page.show("login", "ログイン", false, binding)
	
rescue => exp
	page.show_error(exp)
ensure
end
