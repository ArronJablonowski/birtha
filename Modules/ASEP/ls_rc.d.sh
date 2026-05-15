#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=all
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
# 
#	list the rc.d directory's content.  
#
#	The /etc/rc.d directory contains scripts that control the starting, stopping, and restarting of daemons. The "rc" in /etc/rc.d stands for "run commands" at runlevel.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
#
if [[ -e /etc/rc.d ]]; then
    ls -la /etc/rc.d
else
    echo "NOT_PRESENT: /etc/rc.d"
fi
