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
#	list the contents of sysconfig directory   
#
#	The /etc/sysconfig directory contains files that control the configuration of a system. The contents of this directory depend on the packages installed on the system.	
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
#
if [[ -e /etc/sysconfig ]]; then
    ls -la /etc/sysconfig
else
    echo "NOT_PRESENT: /etc/sysconfig"
fi
