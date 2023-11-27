#!/bin/sh

# ROUND 1 OF MAKER
maker maker_opts_rnd1.ctl maker_bopts_rnd1.ctl maker_exe_rnd1.ctl 2>&1 | tee maker_rnd1_commandoutput.OUT

# Parsing the output of round 1
gff3_merge -s -d HiC_assembly_unmasked_master_datastore_index.log > Lrhomboides_rnd1.all.maker.gff
fasta_merge -d HiC_assembly_unmasked_master_datastore_index.log -o Lrhomboides_rnd1.all.maker

# This fasta merge resulted in a lot of files called Lrhomboides_rnd1.all.maker.all.maker*, so I renamed them to only have one all.maker in the file
name

# Get a gff file without the sequences
gff3_merge -n -s -d HiC_assembly_unmasked_master_datastore_index.log > Lrhomboides_rnd1.all.maker.noseq.gff

# TRAIN GENE PREDICTOR SOFTWARE USING OUTPUT OF MAKER

# TRAINING SNAP
# Create a directory for SNAP
mkdir snap
mkdir snap/rnd1
cd snap/rnd1

# Export confident gene models from MAKER and rename to something meaningful
maker2zff -x 0.25 -l 50 -d ../../HiC_assembly_unmasked.maker.output/HiC_assembly_unmasked_master_datastore_index.log

# Rename the output of this to something meaningful
mv genome.ann Lrhomboides_rnd1.zff.length50_aed0.25.ann
mv genome.dna Lrhomboides_rnd1.zff.length50_aed0.25.dna

# Gather some stats and validate
fathom Lrhomboides_rnd1.zff.length50_aed0.25.ann Lrhomboides_rnd1.zff.length50_aed0.25.dna -gene-stats > gene-stats.log 2>&1
fathom Lrhomboides_rnd1.zff.length50_aed0.25.ann Lrhomboides_rnd1.zff.length50_aed0.25.dna -validate > validate.log 2>&1

# Collect the training sequences and annotations, plus 1000 surrounding bp for training
fathom Lrhomboides_rnd1.zff.length50_aed0.25.ann Lrhomboides_rnd1.zff.length50_aed0.25.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1

# Create the training parameters
mkdir params
cd params
forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

# Assemble the HMM
hmm-assembler.pl Lrhomboides_rnd1.zff.length50_aed0.25 params > Lrhomboides_rnd1.zff.length50_aed0.25.hmm

# TRAINING AUGUSTUS

cd ~/Documents/Pinfish_KME/annotation/MAKER/HiC_assembly_unmasked.maker.output/
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' Lrhomboides_rnd1.all.maker.noseq.gff | awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | bedtools getfasta -fi ../HiC_assembly_unmasked.fa -bed - -fo Lrhomboides_rnd1.all.maker.transcripts1000.fasta
mv Lrhomboides_rnd1.all.maker.transcripts1000.fasta ../
busco -i Lrhomboides_rnd1.all.maker.transcripts1000.fasta -o Lrhomboides_rnd1_maker -l actinopterygii_odb10 -m genome -c 8 --long --augustus --augustus_species zebrafish --augustus_parameters='--progress=true'
rename 's/BUSCO_Lrhomboides_rnd1_maker/Lagodon_rhomboides/g'*
sed -i 's/BUSCO_Lrhomboides_rnd1_maker/Lagodon_rhomboides/g' Lagodon_rhomboides_parameters.cfg
sed -i 's/BUSCO_Lrhomboides_rnd1_maker/Lagodon_rhomboides/g' Lagodon_rhomboides_parameters.cfg.orig1

# Generate EST, protein, and repeat GFF files from original large GFF file. These will also be used as input for a second round of MAKER. 

awk '{ if ($2 == "est2genome") print $0 }' Lrhomboides_rnd1.all.maker.noseq.gff > Lrhomboides_rnd1.all.maker.est2genome.gff
awk '{ if ($2 == "protein2genome") print $0 }' Lrhomboides_rnd1.all.maker.noseq.gff > Lrhomboides_rnd1.all.maker.protein2genome.gff
awk '{ if ($2 ~ "repeat") print $0 }' Lrhomboides_rnd1.all.maker.noseq.gff > Lrhomboides_rnd1.all.maker.repeats.gff

# RUN MAKER AGAIN (round 2.1) USING NEW GENE MODELS

mpiexec -n 20 maker -base Lrhomboides_rnd2.1 maker_opts_rnd2.1.ctl maker_bopts_rnd2.1.ctl maker_exe_rnd2.1.ctl 2>&1 | tee round2.1_run_maker.log

# Compile the output
# First, move into the output directory
cd Lrhomboides_rnd2.1.maker.output
# Then create the output gff and fasta files
gff3_merge -s -d Lrhomboides_rnd2.1_master_datastore_index.log > Lrhomboides_rnd2.1.all.maker.gff
fasta_merge -d Lrhomboides_rnd2.1_master_datastore_index.log
# GFF file with no sequences
gff3_merge -n -s -d Lrhomobies_rnd2.1_master_datastore_index.log > Lrhomboides_rnd2.1.all.maker.noseq.gff

# ASSESS RESULTS

# Let's see how much better the results of this round are, as compared to round 1
# Count the number of gene models and the gene lengths after each round
cat Lrhomboides_rnd2.1.all.maker.gff | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
# Output:
# Number of gene models: 24910
# Average gene length: 11774.7

# Now we can get the same metrics on our round 1 annotation:
cat Lrhomboides_rnd1.all.maker.gff | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
# Output:
# Number of gene models: 29669
# Average gene length: 9445.1

# According to the MAKER development team, as annotations improve, you generally see fewer genes but they tend to be longer, which is what we're seeing here

# We can also visualize the AED distribution
# AED ranges from 0 to 1 and tells you how confident the gene model is based on empirical evidence. The lower the AED, the better. Ideally, 95% or more gene models should have an AED of 0.5 or better if your assembly is good
# We can use the AED_cdf_generator.pl script to help with this visualization
# I got this script from the darencard Boa constrictor MAKER tutorial
# First, we'll run it on the newest genome annotation (round 2.1)
perl AED_cdf_generator.pl -b 0.025 Lrhomboides_rnd2.1.all.maker.gff
# Output:
AED     ./Lrhomboides_rnd2.1.maker.output/Lrhomboides_rnd2.1.all.maker.gff
0.000   0.105
0.025   0.233
0.050   0.405
0.075   0.508
0.100   0.625
0.125   0.685
0.150   0.751
0.175   0.782
0.200   0.817
0.225   0.835
0.250   0.858
0.275   0.871
0.300   0.888
0.325   0.897
0.350   0.911
0.375   0.920
0.400   0.930
0.425   0.936
0.450   0.944
0.475   0.949
0.500   0.955
0.525   0.959
0.550   0.962
0.575   0.965
0.600   0.969
0.625   0.971
0.650   0.974
0.675   0.976
0.700   0.979
0.725   0.981
0.750   0.983
0.775   0.985
0.800   0.987
0.825   0.989
0.850   0.991
0.875   0.993
0.900   0.995
0.925   0.997
0.950   0.998
0.975   0.999
1.000   1.000
# Looks like just about 95% of our genes have an AED < 0.5, so this is good!

# Now let's run it on the previous annotation, to see how much it has improved
perl AED_cdf_generator.pl -b 0.025 ./HiC_assembly_unmasked.maker.output.RND1/Lrhomboides_rnd1.all.maker.gff
# Output:
AED     ./HiC_assembly_unmasked.maker.output.RND1/Lrhomboides_rnd1.all.maker.gff
0.000   0.034
0.025   0.080
0.050   0.154
0.075   0.210
0.100   0.308
0.125   0.383
0.150   0.491
0.175   0.556
0.200   0.631
0.225   0.669
0.250   0.713
0.275   0.737
0.300   0.771
0.325   0.790
0.350   0.820
0.375   0.838
0.400   0.866
0.425   0.882
0.450   0.908
0.475   0.924
0.500   0.940
0.525   0.946
0.550   0.955
0.575   0.961
0.600   0.967
0.625   0.970
0.650   0.974
0.675   0.977
0.700   0.981
0.725   0.983
0.750   0.987
0.775   0.989
0.800   0.992
0.825   0.993
0.850   0.995
0.875   0.996
0.900   0.997
0.925   0.998
0.950   0.999
0.975   1.000
1.000   1.000
# In this previous version, only 94% of genes had an AED < 0.5, so our annotation has improved. This is a good sign!

# Next, we can run BUSCO using the Augustus HMM and look at the results.
# First, we can look at the results of round 1
busco -i Lrhomboides_rnd1.all.maker.transcripts.fasta -o annotation_eval_RND1 -l actinopterygii_odb10 -m transcriptome -c 8 --augustus --augustus_species Lagodon_rhomboides --augustus_parameters='progress=true'
# Output:
INFO:   Results:        C:91.2%[S:89.5%,D:1.7%],F:4.6%,M:4.2%,n:3640

INFO:

        --------------------------------------------------
        |Results from dataset actinopterygii_odb10        |
        --------------------------------------------------
        |C:91.2%[S:89.5%,D:1.7%],F:4.6%,M:4.2%,n:3640     |
        |3319   Complete BUSCOs (C)                       |
        |3257   Complete and single-copy BUSCOs (S)       |
        |62     Complete and duplicated BUSCOs (D)        |
        |167    Fragmented BUSCOs (F)                     |
        |154    Missing BUSCOs (M)                        |
        |3640   Total BUSCO groups searched               |
        --------------------------------------------------

# Next, we can look at the results of round 2.1
busco -i Lrhomboides_rnd2.1.all.maker.transcripts.fasta -o annotation_eval_RND2.1 -l actinopterygii_odb10 -m transcriptome -c 8 --augustus --augustus_species Lagodon_rhomboides --augustus_parameters='progress=true'
# Output:
INFO:   Results:        C:91.3%[S:89.6%,D:1.7%],F:3.1%,M:5.6%,n:3640

INFO:

        --------------------------------------------------
        |Results from dataset actinopterygii_odb10        |
        --------------------------------------------------
        |C:91.3%[S:89.6%,D:1.7%],F:3.1%,M:5.6%,n:3640     |
        |3326   Complete BUSCOs (C)                       |
        |3263   Complete and single-copy BUSCOs (S)       |
        |63     Complete and duplicated BUSCOs (D)        |
        |112    Fragmented BUSCOs (F)                     |
        |202    Missing BUSCOs (M)                        |
        |3640   Total BUSCO groups searched               |
        --------------------------------------------------

# So it looks like our annotation has improved after two rounds of maker! 

# DO SOME FINAL POST-PROCESSING 
# First, convert the gene names to things that are more informative.
maker_map_ids --prefix Lrhomboides Lrhomboides_rnd2.1.all.maker.gff > Lrhomboides_rnd2.1.all.maker.name.map
# Replace names in GFF file. This will overwrite the original, so make a backup copy just in case!
map_gff_ids Lrhomboides_rnd2.1.all.maker.name.map Lrhomboides_rnd2.1.all.maker.gff
map_gff_ids Lrhomboides_rnd2.1.all.maker.name.map Lrhomboides_rnd2.1.all.maker.noseq.gff
# Then, replace names in fasta headers
map_fasta_ids Lrhomboides_rnd2.1.all.maker.name.map Lrhomboides_rnd2.1.all.maker.transcripts.fasta
map_fasta_ids Lrhomboides_rnd2.1.all.maker.name.map Lrhomboides_rnd2.1.all.maker.proteins.fasta

# Some final validation of the results of round 2.1, before we download that to our datastore.
# According to maker developers, most high-quality genome annotations have 55-65% of proteins that contain a recognizable domain. (This is based off of a paper from 2011, so probably better than that by now?)
# We can look at our annotation and see how many genes have a protein domain that is found in the Pfam database.
# Run interproscan to generate a tsv file of proteins within our results that have Pfam domains.
# I ran this from the interproscan folder on Bottlerocket (within the apps directory)
./interproscan.sh -cpu 10 -appl Pfam -iprlookup -goterms -f tsv -i ~/Documents/Pinfish_KME/annotation/MAKER/Lrhomboides_rnd2.1.maker.output/Lrhomboides_rnd2.1.all.maker.proteins.fasta
mv Lrhomboides_rnd2.1.all.maker.proteins.fasta.tsv ~/Documents/Pinfish_KME/annotation/MAKER/Lrhomboides_rnd2.1.maker.output/
# Then, take this information about proteins which have Pfam databases, and integrate that with your genome into the gff files:
ipr_update_gff Lrhomboides_rnd2.1.all.maker.gff LRhomboides_rnd2.1.all.maker.proteins.fasta.tsv > Lrhomboides_rnd2.1.all.maker.ipr.pfam.gff
# Run the script quality_filter.pl to remove transcripts that have AED >= 1.
# The -d option is the default, only removes transcripts with AED >= 1.
quality_filter.pl -d Lrhomboides_rnd2.1.all.maker.ipr.pfam.gff > Lrhomboides_rnd2.1.all.maker.default.ipr.pfam.gff
# The -s option removes transcripts with AED >= 1 BUT if they have a Pfam domain in the gff, it will keep them.
quality_filter.pl -s Lrhomboides_rnd2.1.all.maker.ipr.pfam.gff > Lrhomboides_rnd2.1.all.maker.standard.ipr.pfam.gff
# I don't think I actually need the results of these quality filter scripts, but that is okay

# If we look through our gff file that has the pfam domains, we can count the number of genes doing the following:
grep -cP '\tgene\t' Lrhomboides_rnd2.1.all.maker.ipr.pfam.gff
# OUTPUT:
24910
# Then count the number of genes that contain a Pfam domain:
grep -cP '\tgene\t.*Pfam' Lrhomboides_rnd2.1.all.maker.ipr.pfam.gff
# OUTPUT:
20542

# Therefore, 82.46% of genes in our annotation file have at least one recognizable protein domain.

