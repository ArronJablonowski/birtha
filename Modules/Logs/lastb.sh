#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=logs
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	lastb is the same as last, except that by default it shows a log of the
#       /var/log/btmp file, which contains all the bad login attempts
#		(-w show the fullname )   
#	
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

lastb -w
