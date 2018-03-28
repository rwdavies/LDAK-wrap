#!/usr/bin/env Rscript

message("Begin make test dataset")

## change directory to one up from scripts, no matter how this was called
args <- commandArgs(trailingOnly = FALSE)
for(key in c("--file=", "--f=")) {
    i <- substr(args, 1, nchar(key)) == key
    if (sum(i) == 1) {
        script_dir <- dirname(substr(args[i], nchar(key) + 1, 1000))
        setwd(file.path(script_dir, "../"))
    }
}

source("R/functions.R")

args <- commandArgs(trailingOnly = TRUE)
out_prefix <- args[1]
alpha <- as.numeric(args[2]) ## -0.25 = LDAK, -1 = GCTA
map_filename <- paste0(out_prefix, ".map")
fam_filename <- paste0(out_prefix, ".fam")
ped_filename <- paste0(out_prefix, ".ped")
pheno_filename <- paste0(out_prefix, ".pheno")

h2_g <- 0.5
sigma <- 1 ## of linear phenotype
n_subjects <- 1000

n_chrs <- 10
n_snps <- 10000 ## total number
chrlist <- 1:n_chrs
n_snps_per_chr <- round(n_snps * (seq(n_chrs, 1) / sum(seq(n_chrs, 1))))

sigma_g <- sqrt(h2_g * sigma ** 2)
sigma_e <- sqrt((1 - h2_g) * sigma ** 2)
af <- runif(n_snps, min = 0.05, max = 0.95)
af_mat <- cbind((1 - af) ** 2, (1 - af) ** 2 + 2 * af * (1 - af), 1)

message("Make .map")
map <- make_map(n_chrs, chrlist)

message("Make .fam")
fam <- make_fam(n_subjects)

message("Make genotypes")
out <- simulate_genos(n_subjects, n_snps, af, af_mat, alpha)
G <- out$G
G_ped <- out$G_ped
f <- colSums(G) / n_subjects / 2
X <- normalize_genotype_matrix(G, f, alpha) ## use observed frequency

message("Make phenotypes")
betas <- simulate_betas(map, n_snps, chrlist, af, sigma_g) ## use underlying frequency

pheno <- X %*% betas + rnorm(n = n_subjects, mean = 0, sd = sigma_e)

if (0.1 < abs(var(pheno) - sigma ** 2)) {
    stop(paste0("Faulty assumptions, var(pheno) = ", var(pheno), " and sigma ** 2 = ", sigma**2))
}

message("Write to disk")
write_to_disk(map, map_filename)
write_to_disk(fam, fam_filename)
write_to_disk(cbind(fam, G_ped), ped_filename)
write_to_disk(cbind(fam[, 1:2], pheno), pheno_filename)

message("Done make test dataset")
