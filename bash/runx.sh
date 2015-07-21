#!/bin/bash

script=./NSorter.sh
x=20

time {
for i in $(seq 1 1 $x); do
  echo run $i
  $script
done
}

echo "$script was run $x times"