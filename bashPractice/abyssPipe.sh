#!/bin/bash

#perl ~/Desktop/ngsShoRT_2.1/ngsShoRT.pl -se /mnt/remote/zach/08Aug2014_YChrom/data/B11247*.fastq -5a_f i-m -o ./ -methods lqr_5adpt_tera

#for k in $(seq 21 20 61)
#do

#echo "running k=$k"
#mkdir k$k
#abyss-pe -C k$k name=testabyss1 k=$k se='../trimmed_B11247_S67_L001_R1_001.fastq'
#grep -B1 '.\{200\}' k$k/testabyss1-unitigs.fa | sed "s/--//g" > k$k/testabyss1-unitigs200.fa

#done

#cat k*/testabyss1-unitigs200.fa > B11247-200
#cap3 B11247-200 > all.log
#sed -e 's/\(^>.*$\)/#\1#/' B11247-200.cap.contigs | tr -d "\r" | tr -d "\n" | sed -e 's/$/#/' | tr "#" "\n" | sed -e '/^$/d' > B11247.contigs.fasta 

#rm B11247-200
#makeblastdb -in /mnt/remote/zach/YChromRef-NonScaffold.fasta -input_type 'fasta' -dbtype nucl -title test -out ./test # make database
#blastn -db test -query B11247.contigs.fasta -evalue 1e-3 -outfmt 6 -out B11247_blast.out

#sed 's/[\t].*$//' B11247_blast.out > contignames.txt
sort contignames.txt | uniq > contigs.unique.txt

grep -A1 -F --no-group-separator --no-filename --file=contigs.unique.txt B11247.contigs.fasta > B11247.fa
rm *cap* *log

blastn -db test -query B11247.fa -evalue 1e-3 -outfmt 6 -out B11247_blast.out
