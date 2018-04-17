LDAK-wrap Wrapper around LDAK using Snakemake
=============================================

In progress. Not (yet) for general use

```
# install Snakemake and LDAK
./scripts/install.sh

# make test dataset
./scripts/make-test-dataset.sh

# run on test dataset
./LDAK-wrap.py -p test-results/testdata

# run on test dataset on hpf
./LDAK-wrap.py \
    --prefix test-results/testdata \
    --jobs 100 \
    --workingdir otherLDAKoutput \
    --environment cluster \
    --cluster-config cluster.hpf.json \
    --logdir otherLDAKoutput/logs

```
