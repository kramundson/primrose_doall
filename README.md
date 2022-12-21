# Primrose doall

Primrose doall is a pipeline for analyzing 5mC distribution of a genome assembly from PacBio HiFi data.

## Background

[Primrose][1] is a program for predicting 5mC in CpG contexts from PacBio HiFi reads.
As input, it takes CCS reads, obtained from running [ccs][2] with the ```--hifi-kinetics``` option
and generates an unaligned bam as output.

Identifying 5mC on a genome assembly then requires mapping the reads from primrose to an
assembly using, for example, [pbmm2][3], and then calling 5mC sites with [pb-CpG-tools][4]

This pipeline performs all steps from ccs read generation to methylation calling with user-provided reads and genome assembly:

1. Generate circular consensus reads with kinetics
2. Predict 5mC with primrose
3. Align reads with 5mC calls to a user-provided genome assembly
4. Determine CpG scores from read alignments

## Installation

1. Install miniconda following instructions from the [conda documentation][5]

2. Clone this repo:

```
git clone https://github.com/kramundson/primrose_doall.git
cd primrose_doall
```

3. (optional) Install snakemake through bioconda, can skip if already installed

Note: primrose_doall was tested with snakemake 5.9.1

```
conda install -c bioconda snakemake
```

## Dry run

Does a snakemake dry run on mock genome and subread files

```
snakemake --use-conda --configfile config.yaml -npr
```

In future releases I will include a small test case. I have tested this with ~2 million
HiFi reads and a genome assembly. Results looked reasonable and runtime was about 1 day.

## Run with your own data:

1. Edit ```config.yaml``` for your data

You will want to replace ```test1.bam, test2.bam``` with the names of your subread bam
files. You only need to provide the file names, but the pipeline expects these files to be
in the ```primrose_doall/data/subreads``` folder.

Similarly, put your assembly in the folder ```primrose_doall/asm```, then in ```config.yaml```
replace ```asm.fa``` with the name of your genome assembly file.

2. Rerun the workflow with the modified ```config.yaml``` file

```
snakemake --configfile config_mod.yaml --cores 24
```

You can adjust CPU usage as needed by changing the number provided to ```--cores```

In the future I will add support for multiple reference genomes and cluster parallelization

[1]: https://github.com/PacificBiosciences/primrose
[2]: https://ccs.how/
[3]: https://github.com/PacificBiosciences/pbmm2
[4]: https://github.com/PacificBiosciences/pb-CpG-tools
[5]: https://conda.io/projects/conda/en/stable/user-guide/install/index.html#regular-installation
