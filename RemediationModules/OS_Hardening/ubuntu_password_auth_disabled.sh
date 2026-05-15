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
#   Harden Ubuntu ssh server by disabling password authentication. 
#   *Test keypair auth prior to disabaling.
#   
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# set PasswordAuthentication no
sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 

# set PubkeyAuthentication yes
sudo sed -i -E 's/#?PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config 

# restart service 
service sshd restart 
