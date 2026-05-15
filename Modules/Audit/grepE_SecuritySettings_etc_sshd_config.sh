#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
# description:
#	cat the contents of sshd_config file. 
#
#	sshd_config is the configuration file for the OpenSSH Server. 
# 	ssh_config is the configuration file for the OpenSSH client. (ie. missing the 'd' from sshd.)
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#


# Review the SSH daemon configuration
grep -E "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication" /etc/ssh/sshd_config
