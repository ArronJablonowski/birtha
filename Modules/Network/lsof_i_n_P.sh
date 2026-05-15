#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=network
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,lsof
# description:
#	list open files 
#		(-i option selects the listing of files with Internet addresses) 
#		(-n show numbers/IPs only, and don't resolve IPs to host names) 
#		(-P show the PID/processes ID for the listing ) 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
lsof -i -n -P
