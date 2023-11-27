#!/bin/sh

# Run RepeatModeler on your input genome so you have stuff to input to RepeatMasker which will run inside of Maker
# Run this relative to the folder containing RepeatModeler in ~/Documents/apps

# Build your database, input file is your genome assembly from HiC
./BuildDatabase -name Pinfish_Genome assembly_final.fa

# Run RepeatModeler, the database is the name of the database you just created
./RepeatModeler -engine ncbi -pa 30 -database Pinfish_Genome

# The output files of this are called Pinfish_Genome_Repeats-families.fa and Pinfish_Genome_Repeats-families.stk
