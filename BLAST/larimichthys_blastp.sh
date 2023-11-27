#!/bin/sh

module load blast/2.13.0

makeblastdb -in Larimichthys_crocea_Ensembl107_13Sept22.prot -dbtype prot -out croaker_proteins.DB

blastp -db croaker_proteins.DB -query sparus_unannotated_proteins.fa -out MAKER_proteins_croaker.OUT -outfmt '6 std qcovhsp' -num_threads 10 -evalue 1e-10 
