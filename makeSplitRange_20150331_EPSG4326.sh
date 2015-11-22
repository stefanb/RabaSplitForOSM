#!/bin/bash
start=$1
end=$2

for i in $(seq $start $end); do 
  echo "------ Making split ${i}: -------"
  (time ./makeOneSplitExplode.sh $i) &> RabaSplits_20150331_forest_EPSG4326/rabaForest${i}log.txt;
done
