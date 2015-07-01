#!/bin/bash

# used for contig files
# repeats are unwanted

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


# add in the actual cut repeated sequences
tempResults=tempmyrepeats396
> $tempResults
resultlen=($(wc -l $results))
i=1
while [ $i -le $resultlen ]; do
  repeatline=$(awk -F'\t' -v line="$i" 'NR==line {print $0}' $results)
  echo $repeatline >> $tempResults
  linenum=$(echo $repeatline | awk -F' ' '{print $2}')
  # echo $linenum
  cutsection=$(echo $repeatline | awk -F' ' '{print $3}')
  # echo $cutsection
  contig=$(awk -F'\t' -v line="$linenum" 'NR==line {print $0}' $fafile | cut -c $cutsection)
  # echo $contig
  echo $contig >> $tempResults
  let i+=1
done

cp $tempResults $results
rm -f $tempResults

date +"%m/%d/%Y %H:%M:%S ${0##*/} finished"


# things to consider:
# agrep
# go through, find the actual repeated sequences
# why didn't i add the sequence when doing the results, instead of at the end??