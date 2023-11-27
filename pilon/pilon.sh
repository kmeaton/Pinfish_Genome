#!/bin/sh

REF="flye_assembly.fasta"
FORWARD="adapter_trimmed_mate1.fq.gz"
REVERSE="adapter_trimmed_mate2.fq.gz"

bwa mem -t 40 ${REF} ${FORWARD} ${REVERSE} | samtools view -@ 40 -S -q 15 -b | samtools sort -@ 40 -o ${REF}.sorted.bam

samtools index ${REF}.sorted.bam
mkdir pilon_out
java -Xmx740G -jar '/home/krablab/Documents/apps/pilon/pilon-1.23.jar' --genome ${REF} --frags ${REF}.sorted.bam --output ${REF}.pilon --outdir ./pilon_out/ --fix all

