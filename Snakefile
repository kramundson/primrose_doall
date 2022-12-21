shell.executable("bash")
import re

configfile: "config.yaml"

rule all:
    input:
        expand("data/cpg/{reads}.combined.reference.{suffix}", 
               reads=[re.sub(".bam", "", x) for x in config["reads"]],
               suffix=["bed", "mincov4.bed", "bw", "mincov4.bw"])
            
# runs ccs with --hifi-kinetics option
rule ccs_kinetics:
    input:
        "data/subreads/{reads}.bam"
    output:
        "data/ccs/{reads}.hifi_reads.bam"
    conda:
        "env/ccs.yaml"
    threads: config["threads"]["ccs"]
    log:
        "log/ccs/{reads}.log"
    shell: """
        ccs {input} {output} --hifi-kinetics {threads} > {log} 2>&1
    """
    
# predict 5mC in CpG context with primrose
rule primrose:
    input:
        "data/ccs/{reads}.hifi_reads.bam"
    output:
        "data/primrose/{reads}_5mc.bam"
    conda:
        "env/primrose.yaml"
    threads:
        config["threads"]["primrose"]
    log:
        "log/primrose/{reads}.log"
    shell: """
        primrose -j {threads} {input} {output} > {log} 2>&1
    """
    
# align 5mC reads to genome assembly specified in config.yaml
rule align_5mC:
    input:
        ref=config["asm"],
        bam="data/primrose/{reads}_5mc.bam"
    output:
        "data/aln/{reads}_5mc_aln.bam"
    conda:
        "env/pbmm2.yaml"
    params:
        preset=config["params"]["pbmm2"],
        aln_threads=3*config["threads"]["pbmm2"] // 4,
        sort_threads=config["threads"]["pbmm2"] // 4
    threads:
        config["threads"]["pbmm2"]
    log:
        "log/pbmm2/{reads}.log"
    shell: """
        pbmm2 align \
            {input.ref} \
            {input.bam} \
            {output} \
            {params.preset} \
            -j {params.aln_threads} \
            -J {params.sort_threads} \
            > {log} 2>&1
    """
    
# determine cpg probabilities with pb-cpg-tools
rule aln_to_cpg_scores:
    input:
        ref=config["asm"],
        bam="data/aln/{reads}_5mc_aln.bam"
    output:
        "data/cpg/{reads}.combined.reference.bed",
        "data/cpg/{reads}.combined.reference.mincov4.bed",
        "data/cpg/{reads}.combined.reference.bw",
        "data/cpg/{reads}.combined.reference.mincov4.bw"
    conda:
        "env/conda_env_cpg.yaml"
    params:
        opt=config["params"]["cpg"]["opt"],
        modeldir=config["params"]["cpg"]["modeldir"],
        script=config["params"]["cpg"]["script"]
    threads:
        config["threads"]["cpg"]
    log:
        "log/cpg/{reads}.log"
    shell: """
        python {params.script} \
            -b {input.bam} \
            -f {input.ref} \
            -o data/cpg/{wildcards.reads} \
            -d {params.modeldir}
            {params.opt} \
            -t {threads} \
            > {log} 2>&1
    """