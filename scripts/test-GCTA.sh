#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

## testing, may or may not work

if [ ! -f "gcta_1.91.3beta_mac.zip" ]
then
    curl -O http://cnsgenomics.com/software/gcta/gcta_1.91.3beta_mac.zip
    unzip gcta_1.91.3beta_mac.zip
fi

gcta=gcta_1.91.3beta_mac/bin/gcta64

./scripts/make-test-dataset.sh -1
prefix=test-results/testdata
rm -f ${prefix}.bed
./LDAK-wrap.py --target ${prefix}.bed --prefix=${prefix}

bfile=${prefix}
test=${prefix}.out
${gcta} --bfile ${bfile} --make-grm --out ${test}
${gcta} --reml --grm ${test} --pheno ${bfile}.pheno --out ${test}

cat ${test}.hsq

