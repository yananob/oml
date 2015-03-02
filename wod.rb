#!/usr/local/bin/ruby

require 'cgi'
require 'cgi/session'
require 'class/common'
require 'class/mydb'
require 'erb'
include ERB::Util
require 'kconv'

begin
	mydb = MyDB.new
	cgi = CGI.new
	print cgi.header("charset" => "utf-8")
	
	user = cgi['user']
	
	cmd = cgi['cmd']
	case cmd
	when "show"
#		log.get_log
	
	when "refresh"
		log.crawl
#		log.get_log
	
	else
		sql = "select word, person, ifnull(source, ''), ifnull(source_link, '') " +
		      "  from wod_word " +
		      " where user = ? " +
		      " order by rand() " +
		      " limit 1 "
		res = mydb.query(sql, [user])
		row = res.fetch_row()
		
		word = Kconv.kconv(row[0], Kconv::UTF8)
		person = Kconv.kconv(row[1], Kconv::UTF8)
		source = Kconv.kconv(row[2], Kconv::UTF8)
		source_link = Kconv.kconv(row[3], Kconv::UTF8)
#		source_link.sub!("http://", "")
		
		css_inc = ""
		if (cgi['css'])
			css_inc = cgi["css"]
#			css_inc.sub!("http://", "")
		end
	end
	
	erb = ERB.new(File.read("template/wod.rhtml"))
	print erb.result(binding)
	
rescue => exp
	print exp
ensure
end
