#!/usr/bin/env bash

set -e

# Run all tests while preparing release package and documentation

script_dir=`dirname "$0"`
cd "${script_dir}/../"

./scripts/install.sh

exit 0
