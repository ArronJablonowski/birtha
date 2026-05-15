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
#	cat syslog's content and grep for string 'CRON' 
#
#	Cron logs store the time the a cron job was started, the user account used, and the command ran. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
cat /var/log/syslog | grep CRON
