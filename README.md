# Pinfish_Genome

This repository contains scripts used to assemble and annotate the pinfish genome (*Lagodon rhomboides*).

### Assembly

Raw reads were generated on Oxford Nanopore MinION cells.

Reads were assembled using Flye 2.8-b1674, see the script flye.sh for more detail.

Then, this draft assembly was polished using Illumina reads. These Illumina reads were trimmed using cutadapt, see the script cutadapt.sh for more detail.

Trimmed Illumina reads were used to polish the assembly using the program pilon, see the script pilon.sh for more detail. 

This draft genome was sent to Phase Genomics for HiC scaffolding, which resulted in a highly contiguous assembly with 24 scaffolds, corresponding to the expected number of chromosomes in this species, based off the genome of the gilthead seabream (*Sparus aurata*). 

### Annotation
