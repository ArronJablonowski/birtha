#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,find
# description:
#   Find world/group writable systemd unit files and drop-ins.
#
find /etc/systemd /lib/systemd /usr/lib/systemd -type f \( -name '*.service' -o -name '*.timer' -o -name '*.socket' -o -name '*.path' \) \( -perm -002 -o -perm -020 \) -ls 2>/dev/null
