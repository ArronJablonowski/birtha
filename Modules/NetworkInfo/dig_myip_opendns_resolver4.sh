#!/bin/bash
# description:
#	Uses dig to query the host's external IP using opendns' service. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
dig +short myip.opendns.com @resolver4.opendns.com
