#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh,eslogger
# description:
#   Record EndpointSecurity eslogger availability and supported event names when present.
#
if command -v eslogger >/dev/null 2>&1; then
    eslogger --list-events 2>/dev/null || eslogger --help 2>&1
else
    echo "eslogger not available on this host"
    exit 1
fi
