#!/bin/bash
# description:
#	netstat prints network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. 
#		(-n Show numerical addresses instead of trying to determine symbolic host )
#		(-a Show both listening and non-listening sockets)
#		(-p Show the PID and name of the program to which each socket belongs )
#		(-v Tell the user what is going on by being verbose )
#		(-t tcp )
#		(-u udp) 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
netstat -tuapnv
