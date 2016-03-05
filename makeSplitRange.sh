#!/bin/bash
start=$1
end=$2
dateCompact=${3}${4}${5}

for i in $(seq $start $end); do 
  echo "------ Making split ${i}: -------"
  (time ./makeOneSplitExplode.sh $i $3 $4 $5) &> RabaSplits_${dateCompact}_EPSG4326/raba${i}log.txt;
done
