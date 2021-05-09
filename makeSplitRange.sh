#!/bin/bash
set -e
# set -x

start=$1
end=$2

for i in $(seq $start $end); do
  echo "------ Making split ${i}: -------"
  (time ./makeOneSplitExplode.sh $i $3 $4 $5 $6 ) &> $6/raba${i}log.txt;
done
