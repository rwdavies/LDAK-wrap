#!/usr/bin/env python

from optparse import OptionParser
import subprocess
import os

cur_dir= os.path.dirname(os.path.realpath(__file__))

SNAKEMAKE = cur_dir + "/snakemake/.venv/bin/snakemake"
SNAKEFILE = cur_dir + "/Snakefile"

def main():
    parser = OptionParser(
        usage="usage: %prog [options] target",
	version="%prog 1.0"
    )
    parser.add_option(
        "-e", "--environment",
	action="store",
	dest="environment",
	default="local",
        help="Whether to run locally or on cluster"
    )
    parser.add_option(
        "-t", "--target",
	action="store",
	dest="target",
	default="all",
	help="What target to build"
    )
    parser.add_option(
        "-b", "--bfile",
	action="store",
	dest="bfile",
	default="all",
	help="Path to bfile prefix"
    )
    parser.add_option(
        "-j", "--jobs",
	action="store",
	dest="jobs",
        type=int,
	default=1,
	help="Number of jobs to allow"
    )
    (options, args) = parser.parse_args()

    print(
            " ".join([
                SNAKEMAKE,
                '--snakefile', SNAKEFILE,
                '--jobs', str(options.jobs),
                options.target
            ])
    )

    
    ## todo, do this entirely within Python?
    if options.environment == "cluster":
        subprocess.check_output(
            [
                SNAKEMAKE,
                '--snakefile', SNAKEFILE,
                options.target
            ]
        )
    elif options.environment == "local":
        subprocess.check_output(
            [
                SNAKEMAKE,
                '--snakefile', SNAKEFILE,
                '--jobs', str(options.jobs),
                options.target
            ]
        )
        
if __name__ == '__main__':
    main()
