require 'csv'
require "rexml/document"
include REXML
if ARGV.length >=1
fname = ARGV[0] 
else
fname = "opml.xml"
end

doc = Document.new File.new(fname)
CSV.open('csvfile.csv', 'w') do |writer|
writer << ["URL", "name"]
doc.elements.each("//outline[@type='rss']") {|element|
writer << [element.attribute("xmlUrl").value, element.attribute("title").value]
}
end

