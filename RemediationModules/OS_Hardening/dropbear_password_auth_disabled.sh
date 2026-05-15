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
#   Harden Dropbear (OpenWRT, etc.) ssh server by disabling password authentication. 
#   *Test keypair auth prior to disabaling.
#
# notes: 
#   ecdsa does not work well with all versions of dropbear. Use RSA, or possibly 'ed'.
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit dropbear
/etc/init.d/dropbear restart
