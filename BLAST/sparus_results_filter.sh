#!/bin/sh

blastfile="./MAKER_proteins_seabream.OUT" # the name of your output table from BLAST
goinfo="sparus_gene_GO.tsv" # the name of a file containing gene IDs and descriptions from the species you BLASTED against
mincoverage="50" # how much of the "query" sequence you want to be covered by the "match" sequence (percentage)
minpercentid="75" # how high the percent identity needs to be before you consider something a match
evalue="1e-10" # how low the evalue needs to be before you consider something a match 

# This filters your table based on the parameters given above:
# First, it filters by the query coverage, then it takes the output of that filtering and filters for percent identity, finally, it takes the output of that filtering and filters for e-value. 
# The resulting table is written to a file called multiple_matches.txt
cat $blastfile | awk -v mincov="$mincoverage" '$13 > mincov {print $0}' | awk -v minid="$minpercentid" '$3 >= minid {print $0}' | awk -v ev="$evalue" '$11 < ev {print $0}' > sparus_multiple_matches.txt

# Next, we will get a list of all the transcripts that have annotation information
# This file will be called annotated_transcripts.txt
cat sparus_multiple_matches.txt | awk '{print $1}' | sort | uniq > sparus_annotated_transcripts.txt

# Now, for every transcript listed in that file, search for the name of that transcript in your multiple_matches file, and output that into a file called temp.txt
# Sort the matches based on column 12, which is bit-score
# I would rather that this sort by e-value, but sort doesn't work properly with numbers in exponential notation and I don't know how to get around it. Bit score is also a fine metric to sort by though.
# Then, this program takes the top match (based on bit score) and outputs it into a final file called one_annotation_per_transcript
# Remove the temporary files and then move to next iteration of the loop
for transcript in `cat sparus_annotated_transcripts.txt`
do
    egrep "$transcript\s" sparus_multiple_matches.txt > temp.txt
    sort -nr -k 12 temp.txt > sorted.txt
    head -1 sorted.txt >> sparus_one_annotation_per_transcript.txt
    rm temp.txt
    rm sorted.txt
done

# From the one_annotation_per_transcript file, print ONLY the TRINITY_ID, matching ENSEMBL_ID, percent identity, e-value, bit-score, and query coverage
# Replace any spaces in this file with commas, because spaces are stupid and commas work wonders, output this into a file called ids.txt
cat sparus_one_annotation_per_transcript.txt | awk '{print $1,$2,$3,$11,$12,$13}' | sed -r 's/\s+/,/g' > sparus_ids.txt

# Finally, for each gene in the ids.txt file (contains ensembl and trinity IDs), do the following:
# Search for that gene's ENSEMBL ID in another file, which contains ENSEMBL IDs, gene names, GO terms, and GO accessions
# Output the contents of that search into a temporary file
# Then, for every line in that temporary file, add the associated trinity ID to the beginning of the line, and append this output to annotation_table.csv.
for gene in `cat sparus_ids.txt`
do
        TRINITY=`echo "$gene" | awk -F, '{print $1}'`
        PID=`echo "$gene" | awk -F, '{print $3}'`
        EVAL=`echo "$gene" | awk -F, '{print $4}'`
        BIT=`echo "$gene" | awk -F, '{print $5}'`
        COV=`echo "$gene" | awk -F, '{print $6}'`       
        EI=`echo "$gene" | awk -F, '{print $2}'`
        grep "$EI" $goinfo | sed "s/^ENS/$TRINITY       $PID    $EVAL   $BIT    $COV    ENS/g" >> sparus_annotation_table.tsv
done

# The final output will be a file called annotation_table.tsv. The columns in this table will be, in the following order:
# Trinity ID, Percent Identity of blast match, e-value of blast match, bit-score of blast match, query coverage of blast match, ensembl id, followed by the matching gene info.

# You can use the following code to find UN-annotated contigs that are not in your final annotation file, so they can then be BLASTed or searched for again with a different gene set (like from another species)
# Fill in "name-of-your-transcriptome" with the name of your fasta file containing your transcriptome assembly
# The annotated transcripts.txt file has been generated in the previous steps

module load seqkit/0.14.0

seqkit grep -v -f sparus_annotated_transcripts.txt Lrhomboides_rnd2.1.all.maker.proteins.krakencontamremoved.NOmt.fasta -o sparus_unannotated_proteins.fa
