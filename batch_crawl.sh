#!/bin/sh

# set library path
# http://diaspar.jp/node/135
# http://www.machu.jp/diary/20040806.html
export GEM_HOME=$HOME/lib/ruby/gems/1.8
export RUBYLIB=$HOME/lib/ruby:$HOME/lib/ruby/site_ruby/1.8

cd ~/public_html/oml
/usr/local/bin/ruby ./batch_crawl.rb

exit
