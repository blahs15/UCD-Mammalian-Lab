#!/bin/bash
# last edited 9/21/15

# input files
vcfinputfile=SNPs.vcf
# results files
fastafile=$(sed 's/\(.*\)\.vcf/\1.fasta/' <<<$vcfinputfile )

# changable variables

# temp files
vcffile=${vcfinputfile}.temp
cutfile=clippings.temp
cutfile2=clippings2.temp


##################################################

scriptname=$0
date +"%m/%d %H:%M:%S $scriptname started"

##################################################

> $fastafile
sed -e '/^##.*/ d' -e 's/[ '$'\t'']*$//' -e '/^$/ d' < $vcfinputfile > $vcffile

# . = N , 0 = Ref , 1 = Alt , 2 = 2nd Alt

ids=($(head -1 $vcffile ))
numids=${#ids[@]}
idnum=10 # ids start after normal headers

cut -f4,5 < $vcffile > $cutfile # ref and alt columns
sed -i -e 's/,/'$'\t''/g' $cutfile
filelength=$(wc -l < $cutfile)

# echo outside loop1
# echo $idnum
# echo $numids

while [ $idnum -le $numids ]; do
    # echo loop1
    echo "> ${ids[(($idnum - 1))]}" >> $fastafile

    cut -f$idnum < $vcffile > $cutfile2
    seq=""
    i=2
    while [ $i -le $filelength ]; do
        # echo loop2
        newseq=N  # base pair(s) to be added to seq
        basenum=$(head -n$i $cutfile2 | tail -n1 )
        if [ $basenum != '.' ]; then
            seqarray=($(head -n$i $cutfile | tail -n1 ))
            newseq=${seqarray[$basenum]}
        fi
        seq=${seq}${newseq}
        let i+=1
    done

    echo $seq >> $fastafile
    let idnum+=1
done


rm *.temp

##################################################

date +"%m/%d %H:%M:%S $scriptname finished"


# BUGS
# last id not paired with seq
# INDELS different lengths --> add dashes?
# clippings.temp-e file created??
