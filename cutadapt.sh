#!/bin/bash

#run cutadapt v. 2.3 to remove illumina adapters
cutadapt -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -A GATCGGAAGAGCACACGTCTGAACTCCAGTCACATCACGATCTCGTATGCCGTCTTCTGCTTG --trim-n -q 10 --cores=20 -o adapter_trimmed_mate1.fq.gz -p adapter_trimmed_mate2.fq.gz all_mate1.fq.gz all_mate2.fq.gz
