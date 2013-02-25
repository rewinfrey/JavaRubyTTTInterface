#! /usr/bin/env jruby
$:.unshift File.expand_path "../", __FILE__

require 'lib/ttt_web_interface'
require 'lib/web_game_presenter'
require 'lib/ttt_html_generator'

TTTWebInterface.new(TTTHtmlGenerator.new, WebGamePresenter, RubyLibInterface.new).main
