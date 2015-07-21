#!/bin/bash

tpedfile=file.tped
treemixfile=file.treemix
# number of individuals in each population
popsizes="9 10 20"

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

# step 1.1: get the two base pairs for each line

> $basepairfile
lines=$(wc -l < $tempfile1)
i=1
while [ $i -le $lines ]; do
  line=$(sed -n ${i}p $tempfile1)
  Acount=$(grep -o 'A' <<<$line | wc -l)
  Tcount=$(grep -o 'T' <<<$line | wc -l)
  Gcount=$(grep -o 'G' <<<$line | wc -l)
  Ccount=$(grep -o 'C' <<<$line | wc -l)
  # print two positive counts to $basepairfile
  basepairs=""
  if [ $Acount -gt 0 ]; then basepairs="${basepairs} A"; fi
  if [ $Tcount -gt 0 ]; then basepairs="${basepairs} T"; fi
  if [ $Gcount -gt 0 ]; then basepairs="${basepairs} G"; fi
  if [ $Ccount -gt 0 ]; then basepairs="${basepairs} C"; fi
  echo $basepairs >> $basepairfile
  let i+=1
done

# step 1.2: get the counts of the base pairs into files for each pop

popNum=1 # count for temp files
for pops in $popsizes; do
  poptempfile=${poptempfiles}${popNum}
  > $poptempfile
  cut -f1-$pops $tempfile1 > $tempfile2
  lines=$(wc -l < $tempfile2)
  i=1
  while [ $i -le $lines ]; do
    line=$(sed -n ${i}p $tempfile2)
    bases=$(sed -n ${i}p $basepairfile)
    base1=$(echo $bases | cut -d' ' -f1)
    base2=$(echo $bases | cut -d' ' -f2)

    # base 1
    if [ $base1 == "A" ]; then 
      counts=$(grep -o 'A' <<<$line | wc -l)
    elif [ $base1 == "T" ]; then 
      counts=$(grep -o 'T' <<<$line | wc -l)
    elif [ $base1 == "G" ]; then 
      counts=$(grep -o 'G' <<<$line | wc -l)
    fi

    # base 2
    if [ $base2 == "T" ]; then
      counts2=$(grep -o 'T' <<<$line | wc -l)
    elif [ $base2 == "G" ]; then
      counts2=$(grep -o 'G' <<<$line | wc -l)
    elif [ $base2 == "C" ]; then
      counts2=$(grep -o 'C' <<<$line | wc -l)
    fi
    
    counts=${counts},${counts2}
    echo $counts >> $poptempfile

    let i+=1
  done
  # remove spaces in poptempfile
  sed -i '' 's/, /,/g' $poptempfile

  # remove pop from tempfile
  cut -f${pops}- $tempfile1 > $tempfile2
  rm -f $tempfile1
  mv $tempfile2 $tempfile1
  let popNum+=1
done

# step 1.3: paste pop files together
# space delimited

# rm -f $tempfile1 $tempfile2 $basepairfile

#####################################################

# method 2: do 1 line at a time

date +"%m/%d %H:%M:%S $scriptname finished"
