#!/bin/bash

module load blast/2.13.0

makeblastdb -in Sparus_aurata_Ensembl107_13Sept22.prot -dbtype prot -out seabream_proteins.DB

blastp -db seabream_proteins.DB -query Lrhomboides_rnd2.1.all.maker.proteins.krakencontamremoved.NOmt.fasta -out MAKER_proteins_seabream.OUT -outfmt '6 std qcovhsp' -num_threads 10 -evalue 1e-10 
