#!/usr/bin/env ruby
# A script to sort a list of mp3 files sorted by the duration of the audio file
# Needs the gem ruby-mp3info
# gem install ruby-mp3info

require "rubygems"
require 'mp3info'
def mp3len(dirname)
summary=[]
Dir[dirname].each do |f|
Mp3Info.open(f) do |info|
summary.push([f,info.length])
end
end
summary
end

puts "Enter directory containing mp3 files"
dirname=gets.chomp
dirname = File.expand_path(dirname)
puts "Searching #{dirname}"
dirname += "/**/*.mp3"

s=mp3len(dirname).sort {|a,b| a[1] <=> b[1]}
s.each{|q| puts "#{q[0]} => #{q[1]} seconds"}

