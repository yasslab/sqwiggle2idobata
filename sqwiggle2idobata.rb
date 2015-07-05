#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#require 'rss'
require 'idobata'
require 'sqwiggle-ruby'

Idobata.hook_url = ENV['IDOBATA_END']
Sqwiggle.token   = ENV['SQWIGGLE_API_TOKEN']
client = Sqwiggle.client
messages = client.messages

# NOTE: Heroku Scheduler's frequency should be set to "Every 10 minutes"
updated_msgs = messages.all.select do |msg|
  (Time.now - Time.parse(msg.created_at.to_s)) / 60 <= 10
end


html = ""
updated_msgs.reverse.each { |msg|
  # TODO: Use forked repository until PR is merged
  #name = msg.inspect.split(', "')[1][8..-2]
  name = msg.author.name
  #img  = msg.inspect.split(', "avatar"=>"')[1].split('",').first
  img = msg.author.avatar
  time = msg[:created_at].new_offset(Rational(9, 24)).strftime("%H:%M:%S")
  text = msg[:text].gsub("\n", "<br />")
  h = "<img src='#{img}' width='16px' height='16px' /> <b>#{name}</b>: #{text}<br />"
  html << h
}

puts html
Idobata::Message.create(source: html, format: :html) unless html.empty?
