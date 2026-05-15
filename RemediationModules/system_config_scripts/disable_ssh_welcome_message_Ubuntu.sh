#!/bin/bash
# BIRTHA_TYPE=modify
# BIRTHA_OS=all
# BIRTHA_CATEGORY=modify
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=true
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	Change file mode bits, and remove execution. 
#	This will disable the banner/welcome messages when connecting over ssh. 
#	ie. it will keep extra junk out of the log files. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
#
ls -la /etc/update-motd.d/
echo ''
chmod -x /etc/update-motd.d/*
echo ''
echo 'chmod -x /etc/update-motd.d/*'
echo '' 
ls -la /etc/update-motd.d/
