#!/bin/bash
# description:
#	netstat prints network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. 
#		(-n Show numerical addresses instead of trying to determine symbolic host )
#		(-a Show both listening and non-listening sockets)
#		(-p Show the PID and name of the program to which each socket belongs. )
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
# requires "net-tools" to be installed
#   sudo apt install -y net-tools
#
netstat -nap
