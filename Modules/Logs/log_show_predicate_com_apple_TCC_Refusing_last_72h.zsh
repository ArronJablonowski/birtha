#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=logs
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=zsh,log
# description:
#   Unified Logs: Monitoring TCC (Transparency, Consent, and Control) If malware tried to access the microphone, camera, 
#   or the "Desktop" folder, macOS would have logged the request (and whether it was blocked).
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
log show --predicate 'subsystem == "com.apple.TCC" AND eventMessage CONTAINS "Refusing"' --last 72h 
