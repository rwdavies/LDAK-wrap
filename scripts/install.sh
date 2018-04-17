#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

export USER_OS=`uname -a | cut -f1 -d" "`

if [ "${USER_OS}" == "Darwin" ]
then
    export WGET_OR_CURL="curl -L -O"
else
    export WGET_OR_CURL="wget"
fi

command -v ./snakemake/.venv/bin/snakemake >/dev/null 2>&1 || ./scripts/install-snakemake.sh
command -v ./ldak5.linux >/dev/null 2>&1 || ./scripts/install-LDAK.sh
command -v plink2 >/dev/null 2>&1 || ./scripts/install-plink.sh

