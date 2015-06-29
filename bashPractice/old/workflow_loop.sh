#!/bin/bash
x=1
while [ $x -le 12 ] # "-le " refers to your sample size for the "while loop"
do

      string="sed -n ${x}p filesCanids"

        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1

	./change_workflow_file.sh ${c1}
	./workflow.sh
	./change_workflow_file_back.sh ${c1}

x=$(( $x + 1 ))

done
