#!/bin/bash

# input file
maskedfafile=collated.fa.1.masked.short
# results files
Nseqfile=Nseqs.fa
noNseqfile=savedSeqs.fa

# no Ns allowed in this script
# percentage of Ns allowed -- from 0~100%
# Npercentage=60

####################################################

date +"%m/%d %H:%M:%S NsSorter started"

> $Nseqfile
> $noNseqfile

# seqNum=4
seqNum=($(wc -l $maskedfafile)) # 2x # of seqs (IDs + seqs)

i=1
while [ $i -le $seqNum ]; do
  # echo "line $i:"

  # step 1: get id and sequence at line i and i+1

  # method 1: sed --- FASTER
  id=$(sed -n ${i}p $maskedfafile)
  let i+=1
  seq=$(sed -n ${i}p $maskedfafile)
  let i+=1
  # method 2: head | tail --- SLOWER
  # method 2.1: optimize by getting both lines at once
  # lines=$(head -n$((${i}+1)) $maskedfafile | tail -n2)
  # id=$(echo $lines | awk '{print $1}')
  # seq=$(echo $lines | awk '{print $2}')
  # let i+=2
  # method 2.2: head | tail --- SLOWER than 2.1
  # id=$(head -n${i} $maskedfafile | tail -n1)
  # let i+=1
  # seq=$(head -n${i} $maskedfafile | tail -n1)
  # let i+=1
  # method 3: awk

  ##################################################
  # step 2: find proportion of Ns in seq

  # echo seq: $seq
  # method 1: count, remove Ns, count again
  totalNum=${#seq} # total length
  # echo total: $totalNum
  # method 1.1: take out Ns, count --- Time same as 1.2
  # noNseq=$(tr -d 'N' <<<$seq )
  # noNNum=${#noNseq} # length without Ns
  # method 1.2: take out everything but Ns, count --- Time same as 1.1
  Ns=$(tr -cd 'N' <<<$seq )
  NNum=${#Ns} # length with only Ns

  # method 2: count using grep -c

  #################################################
  # step 3: test proportion vs. allowed %, append to appropriate result file

  # method 1: numerator * 100
  # portion*100/total > % allowed --> tooManyNs
  if [ $NNum -gt 0 ]; then

  # method 2: floating point arithmetic

    echo $id >> $Nseqfile
    echo $seq >> $Nseqfile
  else
    echo $id >> $noNseqfile
    echo $seq >> $noNseqfile
  fi
done

date +"%m/%d %H:%M:%S NsSorter finished"

