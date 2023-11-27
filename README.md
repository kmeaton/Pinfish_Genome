# Pinfish Genome

This repository contains scripts used to assemble and annotate the chromosome-scale genome of the pinfish (*Lagodon rhomboides*).

## Assembly

Raw reads were generated on Oxford Nanopore MinION cells, and assembled using Flye 2.8-b1674 (complete commands used are detailed in `flye.sh`). This yielded an initial draft assembly.

#### Polishing

The initial draft assembly was polished using Illumina reads. 

Raw Illumina reads were trimmed using cutadapt v. 2.3 (complete commands used are detailed in `cutadapt.sh`). Reads were then mapped to the initial draft assembly with bwa-mem v. 0.7.12-r1039 and used to polish this draft assembly using Pilon v. 1.23 (detailed commands of mapping and polishing in `pilon.sh`). 

This draft genome was sent to Phase Genomics for HiC scaffolding, which resulted in a highly contiguous assembly with 24 scaffolds, corresponding to the known karyotype of this species. The complete genome assembly is currently available for reviewers on the GSA FigShare. 

## Annotation

The assembly was iteratively annotated using 
