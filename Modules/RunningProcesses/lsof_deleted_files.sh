#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=process
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,lsof
# description:
#   List deleted-but-open files, a common signal for evasive malware or replaced executables.
#
lsof +L1 2>/dev/null
