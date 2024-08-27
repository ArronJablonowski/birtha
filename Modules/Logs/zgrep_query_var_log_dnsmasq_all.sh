#!/bin/bash
# description:
#	zgrep 'query' from the dnsmasq (dns server) log 
#	will show dns queries 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

zgrep query /var/log/dnsmasq.*
