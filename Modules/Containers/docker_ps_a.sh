#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=containers
# BIRTHA_REQUIRES=user
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=2
# BIRTHA_DEPENDS=bash,docker
# description:
#   List Docker containers with images, status, ports, and commands.
#
docker ps -a --no-trunc
