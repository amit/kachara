#!/usr/bin/env python
import everydnslib,yaml
from time import strftime
filename="dnsbackup-"+strftime("%Y%m%d-%H%M%S")+".yml"
data=yaml.load(file('config.yml').read())
e=everydnslib.EveryDNS(data['username'], data['password'])
records = e.cache_domains()
for record in records:
    record['records'] = e.cache_records(record['domain'])
f= open(filename, "w")
yaml.dump(records,f)
f.close()

