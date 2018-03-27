#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

if [ ! -e virtualenv-15.1.0/virtualenv.py ]
then
    wget https://github.com/pypa/virtualenv/archive/15.1.0.tar.gz
    tar -xzvf 15.1.0.tar.gz
fi

export PATH=`pwd`/virtualenv-15.1.0/:${PATH}

rm -r -f snakemake
wget https://bitbucket.org/snakemake/snakemake/get/v4.8.0.tar.gz
tar -xzvf v4.8.0.tar.gz
mv snakemake-snakemake-e0c4734235c5 snakemake
cd snakemake
virtualenv.py -p python3 .venv
source .venv/bin/activate
python setup.py install