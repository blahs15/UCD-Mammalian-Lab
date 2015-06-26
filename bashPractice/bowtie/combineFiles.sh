#!/bin/bash

# TODO description

if [ $# -ne 2 ] ; then
  echo "usage: CombineInputs.sh input1File input2File"
  echo "omit \".fasta\" and \".fastq\""
  exit 1
fi

input1File=$1
input2File=$2

if [ ! -e $input1File ]; then # test if inputFile exists
  echo "input file 1 \"$input1File\" does not exist"
  exit 1
fi
if [ ! -e $input2File ]; then # test if inputFile exists
  echo "input file 2 \"$input2File\" does not exist"
  exit 1
fi

combinedName=${input1File}__${input2File}

declare -a input1
declare -a input2
# list of the input1s
input1=($(awk -F"\t" '{print $1}' $input1File))
# list of the input2s
input2=($(awk -F"\t" '{print $1}' $input2File))


input1Count=$(wc -w < $input1File)
input2Count=$(wc -w < $input2File)

if [ $input1Count -lt $input2Count ]; then # if input1# < input2#
  # echo IF STATEMENT
  echo -e "$input2\tinput1" > $combinedName
  paste $input2File $input1File >> $combinedName
else # else input1# >= input2#
  # echo ELSE STATEMENT
  echo -e "input1\tinput2" > $combinedName
  paste $input1File $input2File >> $combinedName
fi
