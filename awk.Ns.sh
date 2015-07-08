#!/bin/bash

date +"%m/%d %H:%M:%S this started"

y=($(wc -l collated.fa.1.masked))
(seq 2 2 $y) > numbers
z=($echo $(($y/2)))

x=1
while [ $x -le $z ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p numbers"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)
        c2=$2 #second variable (column 2 in files) This script reads lines one at a time.

sequence=($(awk "NR==${c1}" collated.fa.1.masked | awk '{print length}' -))
Ns=($(awk "NR==${c1}" collated.fa.1.masked | grep -o "N" - | wc -l))
Prop=($(awk "BEGIN { print ( $Ns / $sequence ) }"))

if (( $(echo "$Prop > 0.6" | bc -l) ))
        then
                head -n${c1} collated.fa.1.masked | tail -n2 >> TooManyNs.fasta
        else
                head -n${c1} collated.fa.1.masked | tail -n2 >> Saved.fasta
fi

x=$(( $x + 1 ))

done

date +"%m/%d %H:%M:%S this finally finished"

