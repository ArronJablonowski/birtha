#!/bin/zsh
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
