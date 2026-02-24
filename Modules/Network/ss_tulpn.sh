#!/bin/bash
# description:
#	netstat prints network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. 
#		(-n Show numerical addresses instead of trying to determine symbolic host )
#		(-l Listening sockets ) 
#		(-p Show the PID and name of the program to which each socket belongs )
#		(-t tcp )
#		(-u udp) 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
sudo ss -tulpn
