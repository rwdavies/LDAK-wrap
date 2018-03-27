make_map <- function(n_chrs, chrlist) {
    map <- cbind(
        chr = unlist(sapply(1:n_chrs, function(i_chr) return(rep(chrlist[i_chr], n_snps_per_chr[i_chr])))),
        var_id = paste0("rs", 1:n_snps),
        map = rep(0, n_snps),
        pos = unlist(sapply(1:n_chrs, function(i_chr) return(1:n_snps_per_chr[i_chr])))
    )
    return(map)
}

make_fam <- function(n_subjects) {
    fam <- cbind(
        fid = 1:n_subjects,
        iid = 1:n_subjects,
        father = rep(0, n_subjects),
        mother = rep(0, n_subjects),
        sex = rep(0, n_subjects),
        pheno = rep(0, n_subjects)
    )
    return(fam)
}


quick_sim_geno_one_subject <- function(n_snps, af_mat) {
    g <- array(2, n_snps)
    a <- runif(n_snps)
    for(i in 2:1) {
        g[a < af_mat[, i]] <- i - 1
    }
    return(g)
}

normalize_geno <- function(g, af) {
    return((g - 2 * af) / sqrt(2 * af * (1 - af)))
}


simulate_genos_and_pheno <- function(n_subjects, n_snps, af, af_mat, sigma_e, betas) {
    G <- array(NA, c(n_subjects, 2 * n_snps)) ## order as in PLINK file
    pheno <- array(NA, n_subjects)
    G_first_geno <- seq(1, 2 * n_snps, 1)
    G_second_geno <- seq(1, 2 * n_snps, 1)
    for(i_subject in 1:n_subjects) {
        g <- quick_sim_geno_one_subject(n_snps, af_mat)
        g <- normalize_geno(g, af)
        G[i_subject, G_first_geno] <- as.integer(g == 2)
        G[i_subject, G_second_geno] <- as.integer(1 <= g)
        eps <- rnorm(n = 1, mean = 0, sd = sigma_e)        
        pheno[i_subject] <- sum(betas * g) + eps
    }
    return(
        list(
            G = G,
            pheno = pheno
        )
    )
}


write_to_disk <- function(what, where) {
    write.table(
        what,
        file = where,
        row.names = FALSE,
        col.names = FALSE,
        sep = "\t",
        quote = FALSE
    )
}
