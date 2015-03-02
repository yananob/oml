#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/page'

begin
	cgi = CGI.new
	page = Page.new
	
	page.set_header(cgi)
	
	page.show("help", "ヘルプ", false, binding)
	
rescue => exp
	page.show_error(exp)
ensure
end
