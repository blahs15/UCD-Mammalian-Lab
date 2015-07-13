#!/bin/bash

# input file
maskedfafile=collated.fa.1.masked.short
# results files
Nseqfile=Nseqs.fa
noNseqfile=savedSeqs.fa


date +"%m/%d %H:%M:%S NsSorter started"

> $maskedfafile
> $Nseqfile
> $noNseqfile

# seqNum=($(wc -l collated.fa.1.masked)) # 2x # of seqs
seqNum=4

i=1
while [ $i -le $seqNum ]; do
  echo "line $i:"
  echo $maskedfafile

  # seq=$(awk -F'\t' -v line="$i" 'NR==line {print $0}' $maskedfafile)
  seq=$(sed ${i}p < $maskedfafile) # ?
  
  echo $seq

  let i+=2
done

date +"%m/%d %H:%M:%S NsSorter finished"

