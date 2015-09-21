#!/bin/bash
rm 03.seq 03.fasta 03.vcf
echo ">03" >> 03.fasta

#awk -v var=03 '$1==var' ALL.allsites.2.vcf | grep -v -e "TYPE=complex," -e "TYPE=...,"  > 03.vcf
awk -v var=03 '$1==var' ALL.allsites.vcf | sed 's/\([ATCG]*\),[ATGC]*/\1/g' > 03.vcf

# awk -v var=03 '$1==var' ALL.allsites.vcf > 03.vcf
Y=$(head -n1 03.vcf | awk '{print $2}')
Z=$(tail -n1 03.vcf | awk '{print $2}')
(seq $Y 1 $Z) > numbers
W=($(wc -l numbers))
echo "03"


x=1
while [ $x -le $W ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p numbers"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)

addlength=1

if awk -v var=${c1} '$2==var' 03.vcf | grep -qFw "${c1}"; then

    string1=$(awk -v var=${c1} '$2==var' 03.vcf | grep -Fw "${c1}" | awk '{print $4}')
    string2=$(awk -v var=${c1} '$2==var' 03.vcf | grep -Fw "${c1}" | awk '{print $5}')
    length1=${#string1}
    length2=${#string2}
    if [ $length1 -le $length2 ]; then
        addlength=$length1
    else
        addlength=$length2
    fi

    # echo -n will not put in a newline character
    if echo $string2 | grep -qFw "." ; then
        echo -n $string1 >> 03.seq
    else
        echo -n $string2 >> 03.seq
    fi

else
        echo -n "N" >> 03.seq
fi

#let x+=$addlength
x=$(( $x + $addlength ))
done

echo -e '\n' | cat 03.seq - >> 03.fasta
