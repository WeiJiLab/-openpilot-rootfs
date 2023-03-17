#!/bin/bash

# set python mirror
export PYENV_PYTHON_MIRROR_URL=https://registry.npmmirror.com/binary.html?path=python/3.8.10/

# set pip mirror
PYTHON3=$(which python3)
if [ "${PYTHON3}" == "" ]; then
    sudo apt-get install -y python3
fi

PIP3=$(which pip3)
if [ "${PIP3}" == "" ]; then
    sudo apt-get install -y python3-pip
fi

python3 -m pip install -i https://mirrors.ustc.edu.cn/pypi/web/simple --upgrade pip
pip3 config set global.index-url https://mirrors.ustc.edu.cn/pypi/web/simple

cat <<EOT >>/root/openpilot/pyproject.toml
[[tool.poetry.source]]
name = "tsinghua"
url = "https://pypi.tuna.tsinghua.edu.cn/simple/"
EOT

echo '## Start openpilit env setup ###################################'
cd /root/openpilot
./tools/ubuntu_setup.sh
cd -

# clean
apt-get clean
echo '## Finished openpilit env setup ################################'

exit 0
