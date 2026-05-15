#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash
# description:
#   Collect /etc/ld.so.preload, a high-signal userland rootkit persistence location.
#
if [[ -e /etc/ld.so.preload ]]; then
    ls -la /etc/ld.so.preload
    cat /etc/ld.so.preload
else
    echo "/etc/ld.so.preload not present"
fi
