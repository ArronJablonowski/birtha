#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=process
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	report a snapshot of the current processes
#		(-a Select all processes except both session leaders (see getsid) and processes not associated with a terminal)
#		(-u Select by effective user ID (EUID) or name )
#		(-x this option causes ps to list all processes owned by you (same EUID as ps), or to list ALL processes when used together with the a option)
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
ps jax
