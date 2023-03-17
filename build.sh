#!/bin/bash

function show_usages() {
    echo 'Usages:'
    echo '  -s | --stage  indicates run which stage of build. valid value are "1, 2, 3, all"'
    echo '  -i | --image  target image path'
    echo '  -b | --block-count  block count of target image. 1M per block'
    echo '  -h | --help   show usages'
    echo 'Example:'
    echo "  ./build.sh -s 1 -i './images/rootfs.img' -b 6000"
}

OPTIONS=`getopt -o sibh: --long stage,image,block-count,help -n 'build' -- "$@"`
if [ $? -ne 0 ]; then
    echo '[ERROR] failed to parse arguments'
    show_usages
    exit 1
fi

stage=
image=
bc=
while [ $# -gt 0 ]; do
    case "$1" in
        -s|--stage) shift; stage=`echo "$1" | tr '[:upper:]' '[:lower:]'`; shift;;
        -i|--image) shift; image=$1; shift;;
        -b|--block-count) shift; bc=$1; shift;;
        -h|--help) show_usages; exit 1;;
        --) shift; break;;
        -*|--*) echo "[ERROR] invalid option: '$1'" >&2; show_usages; exit 1;;
        *) show_usages; shift;;
    esac
done

###########################################
# stage 1
###########################################
if [ "${stage}" == "1" ] || [ "$stage" == "all" ]; then
    source ./build-stage-1.sh
    build_stage_1 "${image}" ${bc}
fi

###########################################
# stage 2
###########################################
if [ "${stage}" == "2" ] || [ "$stage" == "all" ]; then
    # clone openpilot
    # need add following lines to ~/.ssh/config
    #   Host github.com
    #       AddKeysToAgent yes
    #       StrictHostKeyChecking no
    #       IdentityFile ~/.ssh/id_rsa
    if [ -d './openpilot' ]; then
        rm -rf './openpilot'
    fi
    git clone git@github.com:WeiJiLab/openpilot.git
    if [ "$?" != "0" ]; then
        exit 1
    fi
    cd openpilot
    git submodule update --init
    cd -

    source ./build-stage-2.sh
    build_stage_2 "${image}"
fi

###########################################
# stage 3
###########################################
if [ "${stage}" == "3" ] || [ "$stage" == "all" ]; then
    source ./build-stage-3.sh
    build_stage_3 "${image}"
fi
