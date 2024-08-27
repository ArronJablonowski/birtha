#!/bin/bash
# description:
#	ip - show / manipulate routing, devices, policy routing and tunnels
#		(-a display all interfaces which are currently available, even if down. )
# 
#	grep 'inet' for a list of current host IPs 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
ip a | grep inet
