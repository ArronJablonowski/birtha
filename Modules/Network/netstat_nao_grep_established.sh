#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=network
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash,netstat
# description:
#	netstat prints network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. 
#		(-n Show numerical addresses instead of trying to determine symbolic host )
#		(-a Show both listening and non-listening sockets)
#		(-o Include information related to networking timers. )
# 	grep for ESTABLISHED connections.  
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
# requires "net-tools" to be installed
#   sudo apt install -y net-tools
#
netstat -nao | grep -i estab
