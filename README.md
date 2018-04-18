LDAK-wrap Wrapper around LDAK using Snakemake
=============================================

[![Build Status](https://travis-ci.org/rwdavies/LDAK-wrap.svg)](https://travis-ci.org/rwdavies/LDAK-wrap)

In progress. Not (yet) for general use

```
# install Snakemake and LDAK
./scripts/install.sh

# make test dataset
./scripts/make-test-dataset.sh

# run on test dataset
./LDAK-wrap.py -p test-results/testdata -t split_chr
./LDAK-wrap.py -p test-results/testdata -t all

# run on test dataset on hpf
./LDAK-wrap.py \
    --prefix test-results/testdata \
    --jobs 100 \
    --workingdir otherLDAKoutput \
    --environment cluster \
    --cluster-config cluster.hpf.json \
    --logdir otherLDAKoutput/logs

```
