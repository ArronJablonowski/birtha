#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=zsh,codesign,ps
# description:
#   Collect code-signing status for running process executable paths on macOS.
#
ps -axo pid=,comm= | while read -r pid exe; do
    [[ -n "$pid" && -n "$exe" && -e "$exe" ]] || continue
    echo "### pid=$pid exe=$exe"
    codesign -dv --verbose=2 "$exe" 2>&1 | egrep 'Authority=|TeamIdentifier=|Identifier=|Runtime Version=|not signed|code object is not signed' || true
done
