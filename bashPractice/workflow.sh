#!/bin/bash
#perl ~/Desktop/ngsShoRT_2.1/ngsShoRT.pl -se /mnt/remote/zach/08Aug2014_YChrom/data/INFILE.fastq*.fastq -5a_f i-m -o ./ -methods lqr_5adpt_tera

for k in $(seq 21 20 61)
do

echo "running k=$k"
mkdir k$k
abyss-pe -C k$k name=testabyss1 k=$k se='../INFILE.fastq'
grep -B1 '.\{200\}' k$k/testabyss1-unitigs.fa | sed "s/--//g" > k$k/testabyss1-unitigs200.fa

done

cat k*/testabyss1-unitigs200.fa > INFILE.fastq-200
cap3 INFILE.fastq-200 > all.log
sed -e 's/\(^>.*$\)/#\1#/' INFILE.fastq-200.cap.contigs | tr -d "\r" | tr -d "\n" | sed -e 's/$/#/' | tr "#" "\n" | sed -e '/^$/d' > INFILE.fastq.contigs.fasta 

rm INFILE.fastq-200
#makeblastdb -in /mnt/remote/zach/YChromRef-NonScaffold.fasta -input_type 'fasta' -dbtype nucl -title test -out ./test # make database
blastn -db test -query INFILE.fastq.contigs.fasta -evalue 1e-150 -outfmt 6 -out INFILE.fastq_blast.out



x=1
while [ $x -le 41 ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p LOCI"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)
        c2=$2 #second variable (column 2 in files) This script reads lines one at a time.


grep -Fw ${c1} INFILE.fastq_blast.out | sed 's/[\t].*$//' - > INFILE.fastq.${c1}.contignames
grep -Fw -A1 --no-group-separator --no-filename --file=INFILE.fastq.${c1}.contignames INFILE.fastq.contigs.fasta > INFILE.fastq.${c1}.contigseqs
sed "s/Contig.*/INFILE.fastq_${c1}/g" INFILE.fastq.${c1}.contigseqs > INFILE.fastq.${c1}.fasta
cat INFILE.fastq.${c1}.fasta >> ${c1}.fasta

x=$(( $x + 1 ))

done



rm -r k* *contig* *log *cap*
