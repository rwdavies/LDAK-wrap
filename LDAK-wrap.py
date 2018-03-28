#!/usr/bin/env python

from optparse import OptionParser
import subprocess
import os
import tempfile
import sys

cur_dir= os.path.dirname(os.path.realpath(__file__))

SNAKEMAKE = cur_dir + "/snakemake/.venv/bin/snakemake"
SNAKEFILE = cur_dir + "/Snakefile"
check_dependencies = cur_dir + "/scripts/check-dependencies.sh"

if platform == "linux" or platform == "linux2":
    LDAK = cur_dir + "/ldak5.linux"
elif platform == "darwin":
    LDAK = cur_dir + "/ldak5.mac"
else:
    sys.exit("LDAK-wrap is only supported for mac and linux")



    


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
        "-p", "--prefix",
	action="store",
	dest="prefix",
	default="jimmy",
	help="Path to plink prefix (e.g. test for test.ped and test.bed"
    )
    parser.add_option(
        "-w", "--workingdir",
	action="store",
	dest="workingdir",
	default="LDAKoutput",
	help="Path for where results go"
    )
    parser.add_option(
        "-j", "--jobs",
	action="store",
	dest="jobs",
        type=int,
	default=1,
	help="Number of jobs to allow"
    )
    parser.add_option(
        "-u", "--unlock",
	action="store_true",
        default=False,
	help="Whether to unlock snakemake"
    )
    (options, args) = parser.parse_args()

    command= [
        'bash', check_dependencies
    ]
    subprocess.check_output(" ".join(command), shell = True)

    with tempfile.NamedTemporaryFile(mode='w') as temp:

        temp.write("LDAK = '" + LDAK + "'\n")        
        temp.write("prefix = '" + options.prefix + "'\n")
        temp.write("workingdir = '" + options.workingdir + "'\n")        
        temp.flush()

        command= [
            'cat', SNAKEFILE, '>>', str(temp.name)
        ]
        subprocess.check_output(" ".join(command), shell = True)
        local_snakefile = temp.name
        

        print(subprocess.check_output(" ".join(["cp", local_snakefile, "temp.Snakefile"]), shell = True)        )
    
        ## todo, do this entirely within Python?
        if options.unlock:
            command = [
                SNAKEMAKE,
                '--snakefile', local_snakefile,
                "--unlock"
            ]
        elif options.environment == "cluster":
            command = [
                SNAKEMAKE,
                '--snakefile', local_snakefile,
                options.target
            ]
        elif options.environment == "local":
            command = [
                SNAKEMAKE,
                '--snakefile', local_snakefile,
                '--jobs', str(options.jobs),
                options.target
            ]

        print(" ".join(command))
        subprocess.check_output(command)



if __name__ == '__main__':
    main()
