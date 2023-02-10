#!/bin/bash
set -e

# Inheriting some environment variables
source ./tools/openpilot_env.sh

# Do some random stuff
echo "Looking form toml files"
find . -name "*.toml"

# Start building
echo "poetry starts a new shell and activates virtual env"
poetry shell

echo "Start building via scons"
scons -u -j$(nproc)
