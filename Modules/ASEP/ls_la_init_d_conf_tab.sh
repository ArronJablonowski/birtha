#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=all
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#
#	list inittab, init.d, init.conf, & init directories 
#
#	>> Init is a daemon that is the first process of a Linux system. It creates processes from scripts stored in the file /etc/inittab. Init is responsible for rebooting, starting, and shutting down the computer
#
#	>> inittab file is the configuration file used by the System V (SysV) initialization system in Linux. This file defines three items for the init process:
#	--the default runlevel
#	-- what processes to start, monitor, and restart if they terminate
#	-- what actions to take when the system enters a new runlevel
#
#	>> Init.d is a directory in the Linux file system that contains scripts for controlling services. These scripts are used to start, stop, reload, and restart services while the system is running or during boot. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
show_path() {
    local label="$1"
    local path="$2"

    echo "#> $label"
    echo "----------"
    if [[ -e "$path" ]]; then
        ls -la "$path"
    else
        echo "NOT_PRESENT: $path"
    fi
    echo ""
}

show_path "Inittab" "/etc/inittab"
show_path "Init.d" "/etc/init.d"
show_path "Init.conf" "/etc/init.conf"
show_path "Init" "/etc/init"
