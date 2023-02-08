#!/bin/bash
set -e

# Inheriting some environment variables
source ./tools/openpilot_env.sh

# Start building
poetry shell && scons -u -j$(nproc)
