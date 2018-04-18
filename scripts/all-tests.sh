#!/usr/bin/env bash

set -e

# Run all tests while preparing release package and documentation

script_dir=`dirname "$0"`
cd "${script_dir}/../"

./scripts/install.sh
rm -r -f test-results
./scripts/make-test-dataset.sh
rm -r -f LDAKoutput
./LDAK-wrap.py -p test-results/testdata -t split_chr
./LDAK-wrap.py -p test-results/testdata -t all

exit 0
