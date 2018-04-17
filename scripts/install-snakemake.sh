#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

if [ ! -e virtualenv-15.1.0/virtualenv.py ]
then
    ${WGET_OR_CURL} https://github.com/pypa/virtualenv/archive/15.1.0.tar.gz
    tar -xzvf 15.1.0.tar.gz
fi

export PATH=`pwd`/virtualenv-15.1.0/:${PATH}

export SNAKEMAKE=`pwd`/snakemake/.venv/bin/snakemake
if [ ! -e ${SNAKEMAKE} ]
then
    echo install snakemake
    echo remove existing snakemake
    rm -r -f snakemake
    echo download
    git clone https://bitbucket.org/snakemake/snakemake.git
    cd snakemake
    git reset --hard 7b489e1
    virtualenv.py -p python3 .venv
    source .venv/bin/activate
    python setup.py install
fi
