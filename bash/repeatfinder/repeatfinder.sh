#!/bin/bash
y=($(wc -l CAP3.collated.fa))

(seq 2 2 $y) > numbers1

w=($(wc -l numbers1))

date +"%m/%d/%Y %H:%M:%S this started"
x=1
while [ $x -le $w ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p numbers1"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)
        c2=$2 #second variable (column 2 in files) This script reads lines one at a time.

echo "line ${c1}" > line
echo "line ${c1}" >> line
echo "line ${c1}" >> line
echo "line ${c1}" >> line

echo "
echo '1-50' > repeatnumber
awk 'NR==${c1}{print;exit}' CAP3.collated.fa | cut -c 1-50 | grep -f - CAP3.collated.fa | wc -l > repeatchecker
echo '100-150' >> repeatnumber
awk 'NR==${c1}{print;exit}' CAP3.collated.fa | cut -c 100-150 | grep -f - CAP3.collated.fa | wc -l >> repeatchecker
echo '200-250' >> repeatnumber
awk 'NR==${c1}{print;exit}' CAP3.collated.fa | cut -c 200-250 | grep -f - CAP3.collated.fa | wc -l >> repeatchecker
paste line repeatnumber repeatchecker > repeat${c1}
cat repeat${c1} >> repeats
rm repeat${c1}" > ${c1}.sh
chmod +x ${c1}.sh
./${c1}.sh
rm ${c1}.sh

x=$(( $x + 1 ))

done

date +"%m/%d/%Y %H:%M:%S this finished"


awk '$4 > "1"{ print $2; }' repeats > RepeatSequences
wc -l RepeatSequences

x=1
while [ $x -le 1000 ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p RepeatSequences"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)
        c2=$2 #second variable (column 2 in files) This script reads lines one at a time.

echo "
awk 'NR==${c1}{print;exit}' CAP3.collated.fa | grep -B1 -f - CAP3.collated.fa >> RepeatSequenceDatabase
" > ${c1}.sh
chmod +x ${c1}.sh
./${c1}.sh
rm ${c1}.sh


x=$(( $x + 1 ))

done

