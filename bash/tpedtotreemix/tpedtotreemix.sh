#!/bin/bash

# This script converts a .tped file to a .treemix file.
# NOT included: the prepending of the population names to the .treemix file

#####################################################
# NOTES:

# seqences with only 1 type of base pair are skipped
# sequences with 3+ types of base pairs won't work properly
# program will only detect characters ATCG

# For Haploid genomes:
# 

#####################################################
# Possible Problems that may occur:

# 1: sed
# sed: can't read s/, /,/g: No such file or directory
# caused due to differences in sed versions
# try replacing the sed line with:
# sed -i 's/, /,/g' $poptempfile

#####################################################

# Example format of .tped file:
# Sequence3378 Sequence3378_333 0 333	T T	C C	T T	T T	T T	T T	T T	T T	T T	T T	T T	T C	T T	T T	T C	T T	T T	T T	T T	T C	T C	T C	T T	T T	T T	T T	T T	T C	T T	T C	T T	T T	T T	T T	T C	T T	T T	T C	T T
# Sequence6726 Sequence6726_366 0 366	G C	G G	G C	G C	G G	G G	C C	G C	G C	G C	G G	G G	G C	G G	G G	G C	G G	G C	C C	G G	G C	C C	G C	G C	G G	C C	G G	G G	G C	G C	G C	G C	C C	G G	G C	C C	C C	G G	G C
# Example format of .treemix file:
# pop1 pop2 pop3
# 16,2 18,2 34,6
# 11,7 15,5 19,21

#####################################################
#####################################################

# input / output file names/data
tpedfile=file.tped
treemixfile=file.treemix
# number of individuals in each population
popsizes="9 10 20"

#####################################################
#####################################################

# temp file names
basepairfile=temp__basepair360.txt
tempfile1=temp__file361.txt
tempfile2=temp__file362.txt
poptempfiles=temp__popfile360.


scriptname=$0
date +"%m/%d %H:%M:%S $scriptname started"

# remove ids
cut -f2- $tpedfile > $tempfile1

#####################################################
# method 1: do 1 population at a time, paste together
#####################################################

# step 1.1: get the two base pairs for each line

> $basepairfile
# basepairfile contains the two base pairs for each corresponding line
lines=$(wc -l < $tempfile1)
i=1
while [ $i -le $lines ]; do
  # get line
  line=$(sed -n ${i}p $tempfile1)
  # get base pair counts
  Acount=$(grep -o 'A' <<<$line | wc -l)
  Tcount=$(grep -o 'T' <<<$line | wc -l)
  Gcount=$(grep -o 'G' <<<$line | wc -l)
  Ccount=$(grep -o 'C' <<<$line | wc -l)
  # print the two positive counts to $basepairfile
  basepairs="$i"
  if [ $Acount -gt 0 ]; then basepairs="${basepairs} A"; fi
  if [ $Tcount -gt 0 ]; then basepairs="${basepairs} T"; fi
  if [ $Gcount -gt 0 ]; then basepairs="${basepairs} G"; fi
  if [ $Ccount -gt 0 ]; then basepairs="${basepairs} C"; fi
  
  base1=base2=""
  base1=$(echo $basepairs | cut -d' ' -f2)
  base2=$(echo $basepairs | cut -d' ' -f3)

  # if only 1 base pair
    echo "line= $i b1= $base1 b2= $base2"
  if [ ! -z $base2 ]; then # checks if empty
    echo $basepairs >> $basepairfile
  else
    echo skipping line $i
  fi
  let i+=1
done

#####################################################

# step 1.2: get the counts of the base pairs into files for each pop

popNum=101 # count for temp files
for pops in $popsizes; do
  # echo "starting pop $popNum"
  poptempfile=${poptempfiles}${popNum}
  > $poptempfile
  # get base pairs of current population
  cut -f1-$pops $tempfile1 > $tempfile2
  lines=$(wc -l < $basepairfile)
  i=1
  while [ $i -le $lines ]; do
    # get base pairs for line
    bases=$(sed -n ${i}p $basepairfile)
    # base1=base2=""
    tpedLineNum=$(echo $bases | cut -d' ' -f1)
    base1=$(echo $bases | cut -d' ' -f2)
    base2=$(echo $bases | cut -d' ' -f3)

    # # if only 1 base pair
    echo "line= $i b1= $base1 b2= $base2"
    # if [ -z $base2 ]; then # checks if empty
    #   # echo "skipping pop $popNum line $i"
    #   let i+=1
    #   continue
    # fi

    # get line
    line=$(sed -n ${tpedLineNum}p $tempfile2)

    # base 1 - get count
    if [ $base1 == "A" ]; then 
      counts=$(grep -o 'A' <<<$line | wc -l)
    elif [ $base1 == "T" ]; then 
      counts=$(grep -o 'T' <<<$line | wc -l)
    elif [ $base1 == "G" ]; then 
      counts=$(grep -o 'G' <<<$line | wc -l)
    fi

    # base 2 - get count
    if [ $base2 == "T" ]; then
      counts2=$(grep -o 'T' <<<$line | wc -l)
    elif [ $base2 == "G" ]; then
      counts2=$(grep -o 'G' <<<$line | wc -l)
    elif [ $base2 == "C" ]; then
      counts2=$(grep -o 'C' <<<$line | wc -l)
    fi
    
    # format/append counts
    counts=${counts},${counts2}
    echo $counts >> $poptempfile

    let i+=1
  done
  # remove spaces in poptempfile
  sed -i '' 's/, /,/g' $poptempfile

  # remove current pop from tempfile
  cut -f$((${pops}+1))- $tempfile1 > $tempfile2
  rm -f $tempfile1
  mv $tempfile2 $tempfile1
  let popNum+=1
done

#####################################################

# step 1.3: paste pop files together
# space delimited

# use globbing? - breaks if more than 10 pops??
# fixed by starting count at 101
paste -d ' ' ${poptempfiles}* > $treemixfile

# use loop?

#####################################################

# step 1.4: cleanup

# if worried there may be more than 2 different base pairs in any line, comment the following line to keep the file.
rm -f $basepairfile
rm -f $tempfile1 $tempfile2 ${poptempfiles}*

#####################################################

# method 2: do 1 line at a time

date +"%m/%d %H:%M:%S $scriptname finished"
