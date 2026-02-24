#!/bin/bash
# description:
#	Browse for mDNS/DNS-SD services using the Avahi daemon - Find nearby hosts using mDNS. 
#		(-a Show all services, regardless of the type) 
#		(-t Terminate after dumping a more or less complete list)  
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
avahi-browse -at
