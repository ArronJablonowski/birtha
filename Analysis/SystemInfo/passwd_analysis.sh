#!/bin/bash
# Analyze passwd-style input for high-risk account anomalies.
# Usage:
#   ./Analysis/SystemInfo/passwd_analysis.sh /path/to/passwd.txt
#   getent passwd | ./Analysis/SystemInfo/passwd_analysis.sh

set -u

input="${1:-/dev/stdin}"

if [[ ! -r "$input" ]]; then
    echo "!!! ERROR !!! -- input not readable: $input" >&2
    exit 1
fi

awk -F: '
    BEGIN {
        print "finding\tuser\tuid\tgid\thome\tshell\traw"
    }
    NF < 7 {
        print "MALFORMED_RECORD\t\t\t\t\t\t" $0
        next
    }
    $3 == 0 && $1 != "root" {
        print "UID0_NONROOT\t" $1 "\t" $3 "\t" $4 "\t" $6 "\t" $7 "\t" $0
    }
    $3 < 1000 && $7 ~ /(bash|zsh|ksh|sh)$/ && $1 != "root" {
        print "SYSTEM_USER_INTERACTIVE_SHELL\t" $1 "\t" $3 "\t" $4 "\t" $6 "\t" $7 "\t" $0
    }
    $6 ~ /^\/(tmp|var\/tmp|dev\/shm)$/ {
        print "SUSPICIOUS_HOME_DIRECTORY\t" $1 "\t" $3 "\t" $4 "\t" $6 "\t" $7 "\t" $0
    }
    $7 !~ /(nologin|false)$/ && $6 == "/" {
        print "INTERACTIVE_USER_ROOT_HOME\t" $1 "\t" $3 "\t" $4 "\t" $6 "\t" $7 "\t" $0
    }
' "$input"
