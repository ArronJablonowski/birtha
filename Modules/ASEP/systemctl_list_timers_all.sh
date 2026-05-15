#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=all
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	Timers are modern cron/scheduled tasks - attackers increasingly use systemd timers because they are less frequently checked than cron.	
#
#   Investigate suspicious timers:
#   If a timer looks odd (e.g., systemd-backup.timer pointing to a script in /tmp), inspect the unit file:
#   systemctl cat <timer_name>
#   systemctl cat <associated_service_name>
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# Systemd timers
systemctl list-timers --all
