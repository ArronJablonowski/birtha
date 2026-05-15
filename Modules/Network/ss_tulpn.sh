#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=network
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash,ss
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
