#!/bin/bash
set -e

# Inheriting some environment variables
source ./tools/openpilot_env.sh

# Since openpilot_env.sh did not add shims to the PATH, we do it here
export PATH=${PYENV_ROOT}/shims:${PATH}

TF="/tmp/tmp.txt"
touch ${TF}
echo "Current python version $(python -V)" >> ${TF}
echo "Current python location $(which python)" >> ${TF}
#echo "ldconfig can find the following:\n$(ldconfig -v)" >> ${TF}

#ln -s ${PYENV_ROOT}/versions/3.8.10/lib/libpython3.8.so /usr/lib/aarch64-linux-gnu/libpython3.8.so

# Start building
echo "poetry starts a new shell and activates virtual env"
poetry shell

# play with poetry
echo "=================================================== After poetry shell" >> ${TF}
#echo "ldconfig can find the following:" >> ${TF}
#echo $(ldconfig -v) >> ${TF}

echo "SConscript files to be revised" >> ${TF}
find . -name SConscript >> ${TF}
scons -u -j$(nproc) --no-test
