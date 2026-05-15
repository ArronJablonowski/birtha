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
# BIRTHA_DEPENDS=zsh,plutil,codesign
# description:
#   Extract executable paths from launchd plists and report code-signing status.
#
for plist in /Library/LaunchAgents/*.plist /Library/LaunchDaemons/*.plist /Users/*/Library/LaunchAgents/*.plist; do
    [[ -r "$plist" ]] || continue
    echo "### plist=$plist"
    plutil -extract Program raw "$plist" 2>/dev/null | while read -r program; do
        [[ -n "$program" && -e "$program" ]] || continue
        echo "program=$program"
        codesign -dv --verbose=2 "$program" 2>&1 | egrep 'Authority=|TeamIdentifier=|Identifier=|not signed|code object is not signed' || true
    done
    plutil -extract ProgramArguments raw "$plist" 2>/dev/null | egrep '^/' | while read -r arg; do
        [[ -e "$arg" ]] || continue
        echo "program_argument=$arg"
        codesign -dv --verbose=2 "$arg" 2>&1 | egrep 'Authority=|TeamIdentifier=|Identifier=|not signed|code object is not signed' || true
        break
    done
done
