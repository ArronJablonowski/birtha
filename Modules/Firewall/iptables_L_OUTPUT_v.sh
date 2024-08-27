#!/bin/bash
# description:
#	List all OUTPUT rules in iptables (packetfilter/firewall) 
#
#	iptables is an administration tool for IPv4 packet filtering and NAT. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
iptables -L OUTPUT -v
