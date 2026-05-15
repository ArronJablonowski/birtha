#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	gets usernames from passwd (database) file, then uses the user's name to sed (stream editor) the user's authorized key's file. Which contains the public keypair for ssh authentication. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
getent passwd |
cut -d : -f 6 |
sed 's:$:/.ssh/authorized_keys:' |
xargs -d '\n' grep -s -H -e "$pattern" 
