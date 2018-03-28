#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

./scripts/install-snakemake.sh
./scripts/install-LDAK.sh
