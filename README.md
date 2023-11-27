# Pinfish Genome

This repository contains scripts used to assemble and annotate the chromosome-scale genome of the pinfish (*Lagodon rhomboides*).

## Assembly

Raw reads were generated on Oxford Nanopore MinION cells, and assembled using Flye 2.8-b1674 (complete commands used are detailed in `flye.sh`). This yielded an initial draft assembly. The log file from Flye, as well as the initial draft assembly info, are housed in the folder "flye". 

#### Polishing

The initial draft assembly was polished using Illumina reads. 

Raw Illumina reads were trimmed using cutadapt v. 2.3 (complete commands used are detailed in `cutadapt.sh`). Reads were then mapped to the initial draft assembly with bwa-mem v. 0.7.12-r1039 and used to polish this draft assembly using Pilon v. 1.23 (detailed commands of mapping and polishing in `pilon.sh`). 

This draft genome was sent to Phase Genomics for HiC scaffolding, which resulted in a highly contiguous assembly with 24 scaffolds, corresponding to the known karyotype of this species. The complete genome assembly is currently available for reviewers on the GSA FigShare. 

#### Removal of contaminants

The program Kraken2 was used to remove any unscaffolded contigs that may have been the result of microbial or off-target contamination. For this, the taxonomic information and genome sequences from the viral, bacterial, and archaeal domains, as well as the complete human genome sequence and the collection of plasmid sequences available on NCBI’s RefSeq database were downloaded. Additionally, we added the complete genome sequences and taxonomic information for three fish species with publicly available genomes on NCBI: Danio rerio (BioProject #PRJNA13922), Larimichthys crocea (BioProject #PRJNA354443), and Lutjanus erythropterus (BioProject #PRJNA662638). The complete database was built using the kraken2-build function in Kraken 2, and then contigs in the pinfish genome were searched and taxonomically classified based on this database, using Kraken 2 with the default parameters. Contigs classified as non-fish in origin were removed from the assembly using the program SeqKit v. 0.14.0. Details of this procedure are available in the script `kraken2.sh`. 

## Annotation

#### MAKER Gene Prediction

The assembly was iteratively annotated using the MAKER annotation pipeline. We began by building a repeat database using the program RepeatModeler v. 2.0.1 (details in `repeatmodeler.sh`). This database was used by MAKER to aid in repeat masking. 

We ran 2 rounds of MAKER, the details of which are summarized in the file `maker.sh`. Briefly, this involved an initial run of the MAKER pipeline. The resulting gene models were parsed from this and used to train the ab-initio gene predictors SNAP and Augustus, which were then used in a second round of gene prediction via the MAKER pipeline. The control files used to run maker are in the "maker" folder. 

#### BLAST Homology Search

To more precisely annotate genes predicted by the MAKER annotation pipeline, we performed a series of iterative BLAST searches for sequence similarity to proteins from publicly available fish genomes. We used the program BLAST+ to search the predicted proteins from the pinfish genome against a database of peptide sequences from the *Sparus aurata* genome downloaded from Ensembl. The results of this search were filtered to include only matches with query coverage >50% and percent identity >= 75%, and the best match for each protein was identified based on bit score. This process was then repeated (for those proteins that did not have a high quality match in the *S. aurata* database), searching against peptides from the *Larimichthys crocea* genome, and then the *Danio rerio* genome. The scripts detailing this process are available in the folder "BLAST". 
