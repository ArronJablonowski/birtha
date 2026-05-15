#!/bin/bash
# BIRTHA_TYPE=modify
# BIRTHA_OS=all
# BIRTHA_CATEGORY=modify
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=true
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	Disable the ssh login message for Red Hat Enterprise Linux  
#	
#	
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
#
ls -la $HOME
echo ""
echo "Adding .hushlogin to $HOME"
cd $HOME && touch .hushlogin
echo ""
ls -la $HOME
