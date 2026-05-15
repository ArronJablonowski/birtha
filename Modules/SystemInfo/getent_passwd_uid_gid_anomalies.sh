#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=system
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,getent,awk
# description:
#   Report UID/GID anomalies including non-root UID 0 accounts and unusual shells.
#
getent passwd | awk -F: '
    $3 == 0 && $1 != "root" { print "UID0_NONROOT " $0 }
    $3 < 1000 && $7 ~ /(bash|zsh|sh)$/ && $1 != "root" { print "SYSTEM_USER_WITH_SHELL " $0 }
    $7 ~ /(nologin|false)$/ { next }
    $6 == "/" || $6 == "/tmp" || $6 == "/dev/shm" { print "SUSPICIOUS_HOME " $0 }
'
