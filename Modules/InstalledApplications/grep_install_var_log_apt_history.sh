#!/bin/bash
# description:
#	grep ' install ' from apt history log
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

grep " install " /var/log/apt/history.log
