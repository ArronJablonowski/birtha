#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh,sqlite3
# description:
#   Query the system TCC database for privacy permission grants.
#
db="/Library/Application Support/com.apple.TCC/TCC.db"
if [[ -r "$db" ]]; then
    sqlite3 -header -column "$db" 'select service, client, client_type, auth_value, auth_reason, last_modified from access;'
else
    echo "TCC database not readable: $db"
    exit 1
fi
