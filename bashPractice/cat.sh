x=1
while [ $x -le 41 ] # "-le " refers to your sample size for the "while loop" (here: 96 samples which is the result of "wc -l files").
do

      string="sed -n ${x}p LOCI"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2}')
        set -- $var
        c1=$1 #the first variable (column 1 in files)
        c2=$2 #second variable (column 2 in files) This script reads lines one at a time.


grep -A1 -Fw ${c1} YChromRef-NonScaffold1.fasta >> ${c1}.fasta

x=$(( $x + 1 ))

done

