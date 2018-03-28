#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

TEST_RESULTS="`pwd`"/test-results
mkdir -p ${TEST_RESULTS}
TEST_PREFIX=${TEST_RESULTS}/testdata

ALPHA=${1:-"-0.25"}

echo Simulating assuming alpha=${ALPHA}
R --slave -f R/make-test-dataset.R --args ${TEST_PREFIX} ${ALPHA}
