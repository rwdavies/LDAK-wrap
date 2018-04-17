
## running LDAK-wrap will inject
## LDAK = path to LDAK
## prefix = prefix to .ped or .bed
## workdir = where to work
## chromosomes_string = chromosomes in string form
## R_DIR = path to R scripts in R directory

chromosomes = [int(x) for x in chromosomes_string.split(",")]

## “power” is exponent to scale minor allele frequency by
## -0.25 is recommended in general
## or to be the same as GCTA set to -1
## this should take some time
LDAK_POWER = -0.25


rule all:
    input:
        [
        workingdir + "/result/pheno1.coeff",
        workingdir + "/partitions/kinships.all.vect.png",
        workingdir + "/partitions/pca.loads.load"	
	]

rule step2:
    input:
        workingdir + "/partitions/kinships.all.grm.bin"

rule step1:
    input:
        workingdir + "/sections/weights.all"

#expand(prefix + ".chr{chr}.bed", chr = chromosomes)

rule make_bed:
    params: N = "make_bed"
    input:
        ped = prefix + ".ped"
    output:
        bed = prefix + ".bed"
    shell:
        'plink --file {prefix} --out {prefix} --make-bed '


rule split_by_chr:
    params: N = "split_by_chr"
    input:
        bed = prefix + ".bed"
    output:
        bed = prefix + ".chr{chr}.bed"
    shell:
        'plink --bfile {prefix} --chr {wildcards.chr} --out {prefix}.chr{wildcards.chr} --make-bed'


## step 1A
rule get_sections_by_chr:
    params: N = "get_sections_by_chr"
    input:
        bed = prefix + ".chr{chr}.bed"
    output:
        workingdir + "/sections/chr{chr}/section.number"
    shell:
        '{LDAK} --bfile {prefix}.chr{wildcards.chr} '
        '--cut-weights {workingdir}/sections/chr{wildcards.chr}'


## step 1B, part 1. since LDAK makes intedeterminate number of files, need to be clever
## so make dummy files, 1 per region to run over
rule prepare_to_make_weights_by_chr:
    params: N = "prepare_to_make_weights_by_chr"
    input:
        workingdir + "/sections/chr{chr}/section.number"
    output:
        dynamic(workingdir + "/sections/chr{chr}/to_run{weight}")
    run:
        with open(input[0], 'r') as infile:
            n_to_make = int(infile.readlines()[0])
            for i in range(1, n_to_make + 1):
                out_file = workingdir + "/sections/chr" + str(wildcards.chr) + "/to_run" + str(i)
                with open(out_file, 'w+') as outfile:
                    outfile.write("1")

## step 1B - make weights per chromosome region
rule make_weights_by_chr:
    params: N = "make_weights_by_chr"
    input:
        bed = prefix + ".chr{chr}.bed",
        inputs = workingdir + "/sections/chr{chr}/to_run{weight}"
    output:
        workingdir + "/sections/chr{chr}/weights.{weight}.done"
    shell:
        '{LDAK} --bfile {prefix}.chr{wildcards.chr} '
        '--calc-weights {workingdir}/sections/chr{wildcards.chr} '
        '--section {wildcards.weight} && touch {output}'

## step1C - merge weights within chromosome together
rule join_weights_by_chr:
    params: N = "join_weights_by_chr"
    input:
        dynamic(workingdir + "/sections/chr{chr}/weights.{weight}.done"),
        prefix + ".chr{chr}.bed"
    output:
        workingdir + "/sections/chr{chr}/weights.all"
    shell:
        '{LDAK} --bfile {prefix}.chr{wildcards.chr} '
        '--join-weights {workingdir}/sections/chr{wildcards.chr}'

## step1D - merge weights per chromosome together
rule join_weights:
    params: N = "join_weights"
    input:
        expand("{w}/sections/chr{chr}/weights.all", w = workingdir, chr = chromosomes)
    output:
        workingdir + "/sections/weights.all"
    shell:
        'head -n1 {input[0]} > {output} && '
        'for chr in {chromosomes}; '
        'do echo $chr; '
        'sed 1d {workingdir}/sections/chr${{chr}}/weights.all >> {output} ;'
        'done'

## stpe2A prepare kinship calculations
rule make_partitions:
    params: N = "make_partitions"
    input:
        bed = prefix + ".bed"        
    output:
        workingdir + "/partitions/partition.details"
    shell:
        '{LDAK} --bfile {prefix} --cut-kins {workingdir}/partitions --by-chr YES'

## step2B calculate kinships
rule calculate_kinships:
    params: N = "calculate_kinships"
    input:
        prefix + ".bed",
        workingdir + "/partitions/partition.details",
        workingdir + "/sections/weights.all"
    output:
        workingdir + "/partitions/kinships.{chr}.grm.bin"
    shell:
        '{LDAK} --bfile {prefix} '
        '--calc-kins {workingdir}/partitions '
        '--partition {wildcards.chr} '
        '--weights {workingdir}/sections/weights.all '
        '--power {LDAK_POWER}'

## to ignore weights
##  --ignore-weights YES

## step2C join kinships
rule join_kinships:
    params: N = "join_kinships"
    input:
        expand("{w}/partitions/kinships.{chr}.grm.bin", w = workingdir, chr = chromosomes)
    output:
        workingdir + "/partitions/kinships.all.grm.bin"
    shell:
        '{LDAK} --bfile {prefix} --join-kins {workingdir}/partitions '

## Optional: this is to produce PCs
rule run_pca:
    params: N = "run_pca"
    input:
        workingdir + "/partitions/kinships.all.grm.bin"
    output:
        workingdir + "/partitions/kinships.all.vect"
    shell:
        '{LDAK} '
        '--grm {workingdir}/partitions/kinships.all '
        '--pca {workingdir}/partitions/kinships.all '	
        '--axes 20'

rule plot_pca:
    params: N = "run_pca"
    input:
        workingdir + "/partitions/kinships.all.vect"
    output:
        workingdir + "/partitions/kinships.all.vect.png"
    shell:
        '{R_DIR}/plot-pca.R --slave --args '
        '{input} '
        '{output} '

## Optional: generate loadings
rule calc_pca_loads:
    params: N = "calc_pca_loads"
    input:
        workingdir + "/partitions/kinships.all.grm.bin",
        prefix + ".bed"
    output:
        workingdir + "/partitions/pca.loads.load"
    shell:
        '{LDAK} '
        '--grm {workingdir}/partitions/kinships.all '
        '--bfile {prefix} '
        '--pcastem {workingdir}/partitions/kinships.all '
        '--calc-pca-loads {workingdir}/partitions/pca.loads '

## Optional: generate loadings
## rule plot_pca_loads:
##     params: N = "plot_pca_loads"
##     input:
##         workingdir + "/partitions/pca.loads.load"
##     output:
##         workingdir + "/partitions/pca.loads.load.temp"
##     shell:
##         '{LDAK} '
##         '--grm {workingdir}/partitions/kinships.all '
##         '--bfile {prefix} '
##         '--pcastem {workingdir}/partitions/kinships.all '
##         '--calc-pca-loads {workingdir}/partitions/pca.loads '


## step3 estimate h2
rule estimate_h2:
    params: N = "estimate_h2"
    input:
        phenofile = prefix + ".pheno",
        grm = workingdir + "/partitions/kinships.all.grm.bin"	
    output:
        workingdir + "/result/pheno1.coeff"
    shell:
        '{LDAK} --pheno {input.phenofile} '
        '--mpheno 1 '
        '--grm {workingdir}/partitions/kinships.all '
        '--reml {workingdir}/result/pheno1'
