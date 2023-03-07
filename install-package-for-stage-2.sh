#!/bin/bash
set -x

echo '## Start openpilit env setup ################################'
cd /openpilot
./tools/ubuntu_setup.sh
cd ..
echo '## Finished openpilit env setup ################################'

exit 0