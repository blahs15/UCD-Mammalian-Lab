#!/bin/bash

fafile=shortCAP3TestFile
results=myrepeats.txt
ranges="1-50 100-150 200-250"

date +"%m/%d/%Y %H:%M:%S ${0##*/} started"

contigs=($(wc -l $fafile))

tempfile=tempFaFile396 # a unique temporary file name
> $tempfile
> $results

i=2
while [ $i -le $contigs ]
do
  contig=$(awk -F'\t' -v line="$i" 'NR==line {print $0}' $fafile)

  for range in $ranges; do
    # echo $range
    
    cutStr=$(echo $contig | cut -c $range)

    # masking replaces repeated strings we don't care about with N's
    strlen=$( echo $cutStr | wc -c )
    # if [ cutStr == $(printf 'N%.s' {1..$strlen}) ]; then # probably slower
    if [ $cutStr == $(head -c $strlen < /dev/zero | tr '\0' 'N') ]; then
      echo "skipping line ${i}, range $range" # testing whether works
      continue
    fi

    # depending on computer, following line may not work
    # repeatnum=$( echo $cutStr | grep -f - $tempfile | wc -l)
    repeatnum=$( echo $cutStr | grep -f /dev/stdin $tempfile | wc -l)
    if [ $repeatnum -gt 0 ]; then
      echo -e "line ${i}\t${range}\t${repeatnum}" >> $results # print results
    fi
  done
  echo $contig >> $tempfile # add to comparisons
  let i+=2 # every other line
done

# progress is found with wc -l tempfile
rm -f $tempfile

date +"%m/%d/%Y %H:%M:%S ${0##*/} finished"


# things to consider:
# agrep
# ignore 'N's
# go through, find the actual repeated sequences