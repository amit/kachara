#!/usr/bin/env python
import time
consume=2 # Size of RAM in GB
snooze=10 # How long to sleep in seconds
print("Eating %s GB ..." % consume)
str1="@"*1024*1024*1024*consume
print("sleeping %s seconds ..." % snooze)
time.sleep(snooze)
print("All Done")
