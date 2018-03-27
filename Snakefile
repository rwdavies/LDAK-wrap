
## running LDAK-wrap will inject prefix into this

chromosomes = list(range(1, 11)) # 1-10, 1-based

rule all:
    input:
        expand(prefix + ".chr{chr}.bed", chr = chromosomes)

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
    wildcard_constraints:
        chr='\d{1,2}'
    shell:
        'plink --file {prefix} --chr {wildcards.chr} --out {prefix}.chr{wildcards.chr} --make-bed'





