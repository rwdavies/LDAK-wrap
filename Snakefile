
## running LDAK-wrap will inject
## LDAK = path to LDAK
## prefix = prefix to .ped or .bed
## workdir = where to work

chromosomes = list(range(1, 11)) # 1-10, 1-based



rule all:
    input:
        workingdir + "/sections/weights.all"

#expand(prefix + ".chr{chr}.bed", chr = chromosomes)

rule make_bed:
    input:
        ped = prefix + ".ped"
    output:
        bed = prefix + ".bed"
    shell:
        'plink --file {prefix} --out {prefix} --make-bed '


rule split_by_chr:
    input:
        bed = prefix + ".bed"
    output:
        bed = prefix + ".chr{chr}.bed"
    shell:
        'plink --file {prefix} --chr {wildcards.chr} --out {prefix}.chr{wildcards.chr} --make-bed'


## step 1A
rule get_sections_by_chr:
    input:
        bed = prefix + ".chr{chr}.bed"
    output:
        workingdir + "/sections/chr{chr}/section.details"
    shell:
        '{LDAK} --bfile {prefix}.chr{wildcards.chr} '
        '--cut-weights {workingdir}/sections/chr{wildcards.chr}'


## step 1B
## since LDAK makes intedeterminate number of files
## need to be clever
rule prepare_to_make_weights_by_chr:
    input:
        workingdir + "/sections/chr{chr}/section.details"
    output:
        dynamic(workingdir + "/sections/chr{chr}/section.details.to_run{weights}")
    shell:
        'n_sections=$(cat {input}) && '
        'echo ${{n_sections}} && '
        'for i in $(seq 1 n_sections); '
        'do touch {input}.to_run${{i}}; '
        'done'

rule make_weights_by_chr:
    input:
        bed = prefix + ".chr{chr}.bed",
        inputs = workingdir + "/sections/chr{chr}/section.details.to_run{weights}"
    output:
        workingdir + "/sections/chr{chr}/section.details.to_see{weights}"
    shell:
        '{LDAK} --bfile {input.bed} '
        '--calc-weights workingdir + "/sections/chr{chr} '
        '--section {wildcards.weights}'

rule join_weights_by_chr:
    input:
        dynamic(workingdir + "/sections/chr{chr}/section.details.to_see{weights}")
    output:
        workingdir + "/sections/chr{chr}/weights.all"
    shell:
        '{LDAK} --bfile {input.bed} '
        '--join-weights {workingdir}/sections/chr{chr}'

rule join_weights:
    input:
        expand("{w}/sections/chr{chr}/weights.all", w = workingdir, chr = chromosomes)
    output:
        workingdir + "/sections/weights.all"
    shell:
        'head -n1 {input[0]} > {output} && '
        'for chr in {chromosomes}; '
        'do echo $chr; '
        'sed 1d {workingdir}/sections/chr{chr}/weights.all >> {output} ;'
        'done'

