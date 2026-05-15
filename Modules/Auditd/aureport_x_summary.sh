#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=all
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
#	 a ranked list of every program that has been launched
#        * requires auditd to be installed 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# a ranked list of every program that has been launched
aureport -x --summary
