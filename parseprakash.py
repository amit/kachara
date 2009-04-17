# Simple script to aggregate students ranks from different websites

import urllib2
import csv
from BeautifulSoup import BeautifulSoup

initials=["A", "B", "C", "D", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "R", "S", "T", "U", "V", "Y"]

urls = ["http://mprakashacademy.co.in/11ResultFiles/%s.htm" % (i.lower()) for i in initials]

resWriter = csv.writer(open('results.csv','w'),lineterminator="\n")

for url in urls:
   data = urllib2.urlopen(url).read()
   soup = BeautifulSoup(data)
   rows=soup.findAll('tr')
   for row in rows:
    rr=row.findAll('td')
    if rr:
        resWriter.writerow([q.string for q in rr])
