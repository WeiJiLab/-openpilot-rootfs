#!/usr/bin/env bash
set -e

# Some environment variables inherited from update_requirements_1.sh
export PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
export PYENV_ROOT="$HOME/.pyenv"
export MAKEFLAGS="-j$(nproc)"

# Now continue to run update_requirements.sh
POETRY_INSTALL_ARGS=""
if [ -d "./xx" ] || [ -n "$XX" ]; then
  echo "WARNING: using xx dependency group, installing globally"
  poetry config virtualenvs.create false --local
  POETRY_INSTALL_ARGS="--with xx --sync"
fi

echo "POETRY_INSTALL_ARGS=$POETRY_INSTALL_ARGS"

echo "pip packages install..."
#poetry install --no-cache --no-root $POETRY_INSTALL_ARGS\

echo "pyenv rehash ..."
#pyenv rehash
