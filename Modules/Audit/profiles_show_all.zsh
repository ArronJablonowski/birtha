#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=zsh
# description:
#   show all configuration profiles.    
#
#   Configuration profiles are used to standardize settings on a Mac. 
#   You can use profiles to impose policies and restrictions on managed Mac machines.
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
profiles show -all
