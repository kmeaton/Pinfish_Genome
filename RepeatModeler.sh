#!/bin/bash

#commands have to be run relative to the folder containing RepeatModeler in ~/Documents/apps

#build your database
./BuildDatabase -name Pinfish_Genome assembly_final.fa

#run RepeatModeler
#you have to check to make sure it is configured correctly
#first, run ./configure
#this might cause some problems, so make sure the shebang line is referring to the correct location of perl
#to find this, run the command which perl, which will tell you where perl is running from
#then, change the shebang line to this location
#you also might have to install some dependencies, I had to install the perl dependency JSON using cpan
#the configure file will take you through a whole setup thing where you specify the locations of a bunch of programs that RepeatModeler will use
#once you're configured, run RepeatModeler
./RepeatModeler -engine ncbi -pa 30 -database Pinfish_Genome

