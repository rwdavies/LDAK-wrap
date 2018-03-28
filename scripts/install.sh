#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

os=`uname -a | cut -f1 -d" "`

if [ "${os}" == "Darwin" ]
then
    export WGET_OR_CURL="curl -L -O"
else
    export WGET_OR_CURL="wget"
fi

./scripts/install-snakemake.sh
./scripts/install-LDAK.sh
