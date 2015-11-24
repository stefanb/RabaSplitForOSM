#!/bin/bash
start=$1
end=$2

for i in $(seq $start $end); do 
  echo "------ Making split ${i}: -------"
  (time ./makeOneSplitExplode.sh $i) &> RabaSplits_20151031_EPSG4326/raba${i}log.txt;
done
