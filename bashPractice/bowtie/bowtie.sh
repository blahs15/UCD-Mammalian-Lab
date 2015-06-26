#!/bin/bash

bowtie2-build -f LOCUS.fasta LOCUS

echo SAMPLE_LOCUS
bowtie2 -x LOCUS --very-fast --no-unal -U SAMPLE.fastq -S SAMPLE_LOCUS.sam 
samtools view -bS SAMPLE_LOCUS.sam | \
samtools sort - SAMPLE_LOCUSs
samtools depth SAMPLE_LOCUSs.bam > SAMPLE_LOCUS.depth.txt


rm *sam
