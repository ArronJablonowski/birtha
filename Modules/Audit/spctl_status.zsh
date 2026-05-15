#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#   Check GateKeeper's status 
#
#   GateKeeper  is a security feature in macOS that ensures only trusted software runs on your Mac. 
#   Gatekeeper verifies downloaded applications before allowing them to run, which reduces the likelihood of inadvertently executing malware. 
#   Gatekeeper is enabled by default on all macOS versions after 10.7.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
spctl --status
