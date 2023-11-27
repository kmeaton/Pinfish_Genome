# Pinfish Genome

This repository contains scripts used to assemble and annotate the chromosome-scale genome of the pinfish (*Lagodon rhomboides*).

## Assembly

Raw reads were generated on Oxford Nanopore MinION cells, and assembled using Flye 2.8-b1674 (complete commands used are detailed in `flye.sh`). This yielded an initial draft assembly. The log file from Flye, as well as the initial draft assembly info, are housed in the folder "flye". 

#### Polishing

The initial draft assembly was polished using Illumina reads. 

Raw Illumina reads were trimmed using cutadapt v. 2.3 (complete commands used are detailed in `cutadapt.sh`). Reads were then mapped to the initial draft assembly with bwa-mem v. 0.7.12-r1039 and used to polish this draft assembly using Pilon v. 1.23 (detailed commands of mapping and polishing in `pilon.sh`). 

This draft genome was sent to Phase Genomics for HiC scaffolding, which resulted in a highly contiguous assembly with 24 scaffolds, corresponding to the known karyotype of this species. The complete genome assembly is currently available for reviewers on the GSA FigShare. 

## Annotation

The assembly was iteratively annotated using the MAKER annotation pipeline. We began by building a repeat database using the program RepeatModeler v. 2.0.1 (details in `repeatmodeler.sh`). This database was used by MAKER to aid in repeat masking. 

We ran 2 rounds of MAKER, the details of which are summarized in the file `maker.sh`. Briefly, this involved an initial run of the MAKER pipeline. The resulting gene models were parsed from this and used to train the ab-initio gene predictors SNAP and Augustus, which were then used in a second round of gene prediction via the MAKER pipeline. The control files used to run maker are in the "maker" folder. 
