#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,getcap
# description:
#   Find Linux file capabilities that may provide privilege-like behavior.
#
getcap -r /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt /tmp /var/tmp /dev/shm 2>/dev/null
