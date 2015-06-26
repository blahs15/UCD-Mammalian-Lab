#!/bin/bash

# DESCRIPTION:
# program runs command on every pair-wise combination of 2 input files

# details:
# combines 2 input files
# gets each pair-wise combination of each word in input1File with each word in input2File
# runs script with each pair
# script input1 input2

input1File=LOCI
input2File=SAMPLES
myscript=/home/Russel/bashPractice/bowtie/mybowtie.sh


if [ $# -eq 2 ] ; then # optional command line input
  input1File=$1
  input2File=$2
fi

./combineFiles.sh $input1File $input2File

file=${input1File}__${input2File}

echo "$file : "

firstCol=$(head -1 $file | cut -f1) #first word

tail -n +2 $file > temp$file # later replace with sed statement?
cp temp$file $file

# list of the words in the 1st column
col1=$(awk -F"\t" '{print $1}' $file)
# echo $col1

# list of the words in the 2nd column
col2=$(awk -F"\t" '{print $2}' $file)
# echo $col2

# echo "nested loop:"
# actions using every pair-wise combination (every permutation)
for c1 in $col1; do
  for c2 in $col2; do
    : # no-op command in case loop is empty
    # echo $c1 : $c2 # prints out each pair-wise combination

    tempc1=$c1
    tempc2=$c2
    if [ "$firstCol" == "input2" ]; then #swap
      temp=$tempc1
      tempc1=$tempc2
      tempc2=$temp
    fi
    # echo $tempc1 $tempc2
    $myscript $tempc1 $tempc2
  done
done

rm -f temp$file
rm -f $file
echo "DONE"
