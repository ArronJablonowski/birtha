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
#	zgrep all syslog files including *.gz archives (without needing to unzip/untar) for the string 'CRON'
#
#	Syslogs store the time the a cron job was started, the user account used, and the command ran.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
zgrep 'CRON' /var/log/syslog*
