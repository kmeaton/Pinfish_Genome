#!/bin/sh

module load blast/2.13.0

makeblastdb -in Danio_rerio_Ensembl107_13Sept22.prot -dbtype prot -out zebrafish_proteins.DB

blastp -db zebrafish_proteins.DB -query croaker_unannotated_proteins.fa -out MAKER_proteins_zebrafish.OUT -outfmt '6 std qcovhsp' -num_threads 10 -evalue 1e-10
