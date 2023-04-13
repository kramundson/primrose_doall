#!/bin/bash
#
#SBATCH --job-name=primrose_doall
#SBATCH -c 1 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem=2G # Memory pool for all cores in MB (see also --mem-per-cpu)
#SBATCH --time 3-00:00:00 # 3 day runtime
#SBATCH -p production # Partition to submit to
#SBATCH -o primrose_doall.out # File to which STDOUT will be written
#SBATCH -e primrose_doall.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user= # Email to which notifications will be sent

date
hostname

WORKDIR=# your wd here
# CONDA='oak'# optional, your conda env here

cd $WORKDIR
# conda activate $CONDA # optional

snakemake \
	-j 999 \
	-s Snakefile \
	--rerun-incomplete \
	--configfile config.yaml \
	--cluster-config cluster.yaml \
	--cluster "sbatch -p {cluster.partition} -n {cluster.n} -t {cluster.time} -c {cluster.c} --mem-per-cpu {cluster.mempercpu}" \
	 -k \
	-w 120

date
exit
