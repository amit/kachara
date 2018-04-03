#!/bin/sh
openssl speed -multi $(grep -ci processor /proc/cpuinfo)
