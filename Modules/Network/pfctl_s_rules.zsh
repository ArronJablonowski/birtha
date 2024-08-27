#!/bin/zsh
# description:
#	controls the packet filter (pf) and netowrk address translation (NAT) device. 
#	(-s -- shows the current rules)  
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
pfctl -s rules
