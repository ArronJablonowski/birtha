#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=system
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	chkconfig --list will display a list of all services and their current configuration.
#
#	If your machine has it installed, run chkconfig to see which services are enabled at various runlevels. The output will show the service name, the runlevel(s) in which the service is enabled, and the startup priority for each runlevel. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
chkconfig --list
