#!/bin/bash
# description:
#	dmesg - print or control the kernel ring buffer
#	grep for 'hd' hardware events 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
dmesg | grep hd
