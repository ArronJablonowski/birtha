#!/bin/bash
# description:
#	Disable the ssh login message for RaspberryPi OS 
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