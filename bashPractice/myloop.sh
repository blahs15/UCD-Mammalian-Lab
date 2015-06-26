#!/bin/bash

# set default "inputFileName" to the file that contains a list (new line separated) of the files you want to run the script on
#example: inputFileName=YourFilePath
inputFileName=inputfile

# usage: ./myloop.sh YourInputFile
if [ $# -ge 1 ]; then # if YourInputFile is given on command line
  inputFileName=$1
fi
echo "inputfile: $inputFileName"
if [ ! -e $inputFileName ]; then # test if inputFile exists
  echo "inputfile \"$inputFileName\" does not exist"
  exit 1
fi
echo ""

#puts all file names into a single list
files=$(cat $inputFileName | tr "\\n" " ")

for file in $files; do #loop runs on each file
  echo "$file : "

  declare -a col1ar # declare variables as arrays
  declare -a col2ar

  # list of the words in the 1st column
  col1=$(awk -F"\t" '{print $1}' $file)
  col1ar=($col1)
  # echo $col1

  # list of the words in the 2nd column
  col2=$(awk -F"\t" '{print $2}' $file)
  col2ar=($col2)
  # echo $col2


  # echo "col1 loop:"
  # actions using the just the list of words in 1st column
  for word in $col1; do
    : # no-op command in case loop is empty
    # echo $word # prints out each word on separate line

  done # for col1

  # echo "col2 loop:"
  # actions using the just the list of words in 2nd column
  for word in $col2; do
    : # no-op command in case loop is empty
    # echo $word # prints out each word on separate line

  done # for col2

  # echo "nested loop:"
  # actions using every pair-wise combination (every permutation)
  for c1 in $col1; do
    for c2 in $col2; do
      : # no-op command in case loop is empty
      # echo $c1 : $c2 # prints out each pair-wise combination

    done
  done

  # echo "multiple cols loop:"
  #actions using lists of words in multiple columns
  i=0
  while [ $i -lt ${#col1ar[*]} ]; do
    # access each column 1 word with ${col1ar[$i]}
    # access each column 2 word with ${col2ar[$i]}
    # echo ${col1ar[$i]} : ${col2ar[$i]}

    let i+=1 # iteration in loop, do not comment out
  done # for 

  echo "$file DONE"
  echo ""
done # for files