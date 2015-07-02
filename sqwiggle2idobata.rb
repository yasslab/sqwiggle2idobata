#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#require 'rss'
require 'idobata'
require 'sqwiggle-ruby'

Idobata.hook_url = ENV['IDOBATA_END']
Sqwiggle.token   = ENV['SQWIGGLE_API_TOKEN']
client = Sqwiggle.client
messages = client.messages

# NOTE: Heroku Scheduler's frequency should be set to "Hourly"
updated_msgs = messages.all.select do |msg|
  (Time.now - Time.parse(msg.created_at.to_s)) / 60 <= 10
end


text = ""
updated_msgs.reverse.each { |msg|
  name   = msg.inspect.split(', "')[1][8..-2]
  time   = msg[:created_at].new_offset(Rational(9, 24)).created_at.strftime("%H:%M%S")
  m = "<b>#{name}</b>: #{msg[:text]} (#{time})<br />"
  text << m
}

puts text
Idobata::Message.create(source: text, format: :html) unless text.empty?
