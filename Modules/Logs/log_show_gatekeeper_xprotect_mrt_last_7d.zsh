#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=logs
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=zsh,log
# description:
#   Query recent macOS Gatekeeper, XProtect, MRT, syspolicyd, and trust evaluation logs.
#
log show --style syslog --last 7d --predicate 'process == "syspolicyd" OR process CONTAINS "XProtect" OR process CONTAINS "MRT" OR subsystem CONTAINS "com.apple.security" OR eventMessage CONTAINS "Gatekeeper" OR eventMessage CONTAINS "XProtect" OR eventMessage CONTAINS "MRT"' 2>&1
