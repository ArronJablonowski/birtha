#!/bin/zsh
# description:
#   Unified Logs: Monitoring TCC (Transparency, Consent, and Control) If malware tried to access the microphone, camera, 
#   or the "Desktop" folder, macOS would have logged the request (and whether it was blocked).
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
log show --predicate 'subsystem == "com.apple.TCC" AND eventMessage CONTAINS "Refusing"' --last 72h 
