require 'csv'
require 'open-uri'
require "rexml/document"
include REXML
if ARGV.length >=1
fname = ARGV[0] 
else
#fname = "opml.xml"
puts "Usage: #{$0} opml_file_or_url"
exit
end

handle=open(fname)
doc = Document.new handle
CSV.open('csvfile.csv', 'w') do |writer|
writer << ["URL", "name"]
doc.elements.each("//outline[@type='rss']") {|element|
writer << [element.attribute("xmlUrl").value, element.attribute("text").value]
}
end

