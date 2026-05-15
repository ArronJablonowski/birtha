#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=filesystem
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=bash
# description:
#	Uses the find command to search the /home folder for the x number of largest files. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /home -printf '%s %f\n'| sort -nr | head -75

