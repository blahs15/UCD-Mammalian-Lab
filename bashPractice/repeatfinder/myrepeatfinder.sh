#!/bin/bash

faFile=shortCAP3TestFile

contigs=($(wc -l $faFile))

date +"%m/%d/%Y %H:%M:%S ${0##*/} started"

i=2
while [ $i -le $contigs ]
do
  
  let i+=2 # every other line
done

date +"%m/%d/%Y %H:%M:%S ${0##*/} finished"
