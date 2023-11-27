#!/bin/sh

cd ~/Documents/apps/kraken2/

# Build the standard kraken2 database

#./kraken2-build --use-ftp --standard --threads 6 --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db
# This quit part of the way through downloading the bacteria database, run the following commands afterwards

#./kraken2-build --threads 6 --use-ftp --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --download-library viral
#./kraken2-build --threads 6 --use-ftp --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --download-library bacteria
#./kraken2-build --threads 6 --use-ftp --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --download-library plasmid
#./kraken2-build --threads 6 --use-ftp --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --download-library human --no-mask
#./kraken2-build --add-to-library /mnt/sdb3/Katie_Pinfish_Genome/Lutjanus_erythropterus_taxid.fa --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --threads 6
# Add Larimichthys crocea which is taxid 215358
#./kraken2-build --add-to-library /mnt/sdb3/Katie_Pinfish_Genome/L_crocea_taxid.fa --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --threads 6
# Add Danio rerio which is taxid 7955
#./kraken2-build --add-to-library /mnt/sdb3/Katie_Pinfish_Genome/D_rerio_taxid.fa --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --threads 6

# Build database
./kraken2-build --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db --build --threads 6

# Search new database
./kraken2 --db /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_db /mnt/sdb3/Katie_Pinfish_Genome/HiC_assembly_unmasked.fa --threads 8 --report /mnt/sdb3/Katie_Pinfish_Genome/kraken2_standard_3feb22.out > full_kraken_report_stdout_3feb22.out
