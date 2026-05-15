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
# BIRTHA_DEPENDS=bash,lsof
# description:
#	list open files 
#		(-i option selects the listing of files with Internet addresses) 
#		(-n show numbers/IPs only, and don't resolve IPs to host names) 
#		(-P show the PID/processes ID for the listing ) 
# 
#	grep for ESTABLISHED connections
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
lsof -i -n -P | grep -i estab
