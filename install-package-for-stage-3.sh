#!/bin/bash

source /root/.bashrc
cd /root/openpilot
/root/.pyenv/shims/poetry run scons -u -j$(nproc)
