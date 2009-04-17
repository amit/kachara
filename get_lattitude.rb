#!/bin/env ruby
# Simple ruby script to get lattitude and longitude of any place
# Specify the address in a line with any level of detail
# It also shows ZIP+4 for a given street address
require 'open-uri'
require "rexml/document"
include REXML
url='http://api.local.yahoo.com/MapsService/V1/geocode?appid=yahoomap.rb&location='
puts 'Enter Location: '
address=gets
address=URI.escape(address)
result=URI(url+address).read
doc = Document.new result
r=doc.elements["/ResultSet/Result"]
print "Precision: ", r.attributes["precision"],"\n"
r.children.each { |c| print c.name, " : ",c.text,"\n"}
