#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=user
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,systemctl
# description:
#   List user-level systemd services and timers.
#
systemctl --user list-units --type=service,timer --all --no-pager
