#!/usr/bin/env Rscript

message("Begin plot PCA")

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
vect_file <- args[1]
out_png <- args[2]

## vect_file <- "/home/rwdavies/proj/LDAK-wrap/LDAKoutput/partitions/kinships.all.vect"; out_png <- "/home/rwdavies/proj/LDAK-wrap/LDAKoutput/partitions/kinships.all.vect.png"
## vect_file <- "/hpf/largeprojects/tcagstor/scratch/rwdavies/geno_build/2018_04_05/LDAK/partitions/kinships.all.vect"; out_png <- "/hpf/largeprojects/tcagstor/scratch/rwdavies/geno_build/2018_04_05/LDAK//partitions/kinships.all.vect.png"

vect <- read.table(vect_file)
colnames(vect) <- c("ID1", "ID2", paste0("PC", 1:(ncol(vect) - 2)))

f <- function(x, y) {
    plot(vect[, x], vect[, y], xlab = x, ylab = y)
}

message(paste0("Making plot to:", out_png))
png(out_png, height = 8, width = 8, units = "in", res = 300)
par(mfrow = c(2, 2))
f("PC1", "PC2")
f("PC1", "PC3")
f("PC2", "PC3")
f("PC3", "PC4")
dev.off()

message("Done")
