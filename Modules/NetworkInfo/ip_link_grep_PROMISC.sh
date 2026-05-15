#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=network
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
#
# 
#	Display's system's ARP table. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
ip link | grep PROMISC
