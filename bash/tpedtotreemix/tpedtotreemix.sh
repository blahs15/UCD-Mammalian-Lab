#!/bin/bash

# This script converts a .tped file to a .treemix file.
# NOT included: the prepending of the population names to the .treemix file
# step 1.1.2 MUST be commented out if not haploid data

#####################################################
# NOTES:

# seqences with only 1 type of base pair are skipped
# sequences with 3+ types of base pairs won't work properly
# program will only detect characters ATCG

# For Haploid genomes:
# step 1.1.2 will skip lines that contain a heterozygote for any individual in that line

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
tpedfile=Y2.tped
# number of individuals in each population
popsizes="10 6 20"


# don't need to be changed:
tpedfileNoExt=$(sed s/.tped//g <<<$tpedfile )
treemixfile="${tpedfileNoExt}.treemix"
filteredtpedfile="${tpedfileNoExt}.filtered.tped" # output a filtered tped file
basepairfile="${tpedfileNoExt}.basepairs"
filteredtpedheterofile="${tpedfileNoExt}.filtered.heterozygous.tped" # output a filtered tped file
basepairheterofile="${tpedfileNoExt}.basepairs.heterozygous"



# to clean up all output files without running script
# rm -f $treemixfile $filteredtpedfile $basepairfile $filteredtpedheterofile $basepairheterofile
# exit 0
#####################################################
#####################################################

# temp file names
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
echo step 1.1

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
  base1=$(cut -d' ' -f2 <<<$basepairs )
  base2=$(cut -d' ' -f3 <<<$basepairs )

  # if only 1 base pair
  # echo "line= $i, b1= $base1, b2= $base2"
  if [ ! -z $base2 ]; then # checks if not empty
    heterozygous=false # for step 1.1.2, but should not be commented out

    #####################################################
    #####################################################
    # step 1.1.2: for haploids
    # MUST BE COMMENTED OUT IF NOT HAPLOID DATA
    # remove lines that contain heterozygote pairs within an individual
    
    # check first two chars at a time
    # shift to next pair
    while [ ! -z "$line" ]; do
      # get first two chars
      templine=$(cut -f1 <<<$line )
      b1=$(cut -d' ' -f1 <<<$templine )
      b2=$(cut -d' ' -f2 <<<$templine )

      if grep -q $b1 <<<"ATGC" && [ $b1 != $b2 ]; then
        # must be ATCG char && b1 == b2
        heterozygous=true
        break
      fi

      line=$(echo "$line" | cut -s -f2- ) # get remainder of line
    done
    #####################################################
    #####################################################

    # a check for step 1.1.2, but should not be commented out
    if [ $heterozygous = false ]; then
      echo $basepairs >> $basepairfile
    else
      echo $basepairs >> $basepairheterofile
    fi
  fi
  let i+=1
done

#####################################################

# step 1.2: create a .filtered.tped file that only has the included lines
echo step 1.2

> $filteredtpedfile
i=1
lines=$(wc -l < $basepairfile)
while [ $i -le $lines ]; do
  tpedLineNum=$(sed -n ${i}p $basepairfile | cut -d' ' -f1)
  sed -n ${tpedLineNum}p $tpedfile >> $filteredtpedfile
  let i+=1
done

> $filteredtpedheterofile
i=1
lines=$(wc -l < $basepairheterofile)
while [ $i -le $lines ]; do
  tpedLineNum=$(sed -n ${i}p $basepairheterofile | cut -d' ' -f1)
  sed -n ${tpedLineNum}p $tpedfile >> $filteredtpedheterofile
  let i+=1
done

#####################################################

# step 1.3: get the counts of the base pairs into files for each pop
echo step 1.3

cut -f2- $filteredtpedfile > $tempfile1

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
    base1=$(cut -d' ' -f2 <<<$bases )
    base2=$(cut -d' ' -f3 <<<$bases )

    # echo "line= $tpedLineNum, basepair= $i, b1= $base1, b2= $base2"

    # get line
    line=$(sed -n ${i}p $tempfile2)
    counts=counts2=0

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

echo step 1.4
# step 1.4: paste pop files together
# space delimited

# globbing will only work with <900 populations
paste -d ' ' ${poptempfiles}* > $treemixfile

#####################################################

echo step 1.5
# step 1.5: cleanup

# if worried there may be more than 2 different base pairs in any line, comment the following line to keep the file.
# rm -f $basepairfile
rm -f $tempfile1 $tempfile2 ${poptempfiles}*
rm -f *.filtered.tped.filtered.tped

echo "INPUT file: $tpedfile"
echo "OUTPUT files:"
echo $treemixfile
echo $filteredtpedfile
echo $basepairfile
echo $filteredtpedheterofile
echo $basepairheterofile

#####################################################

date +"%m/%d %H:%M:%S $scriptname finished"
