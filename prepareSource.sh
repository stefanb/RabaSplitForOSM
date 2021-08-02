#!/bin/bash
set -e
# set -x

echo "Starting RABA split at $(date)"

# default: http://stackoverflow.com/questions/16835145/how-to-get-last-day-of-last-month-in-unix
#date --date="yesterday" +"%d-%m-%y"
yyyy=`date -d "$(date +%Y-%m-01) -1 day" +"%Y"`
dd=`date -d "$(date +%Y-%m-01) -1 day" +"%d"`
#dd="02"
mm=`date -d "$(date +%Y-%m-01) -1 day" +"%m"`
#mm="08"

#set parameters:
#yyyy="2021"
#dd="31"
#mm="03"

#internal variables...
dateSource="${yyyy}_${mm}_${dd}"
dateCompact="${yyyy}${mm}${dd}"

echo "Processing RABA data for ${yyyy}-${mm}-${dd}"

#------ download:------
sourceRar="RABA_${dateSource}.RAR"
if [ ! -f ${sourceRar} ]; then
    echo "Downloading ${sourceRar}..."
    wget http://rkg.gov.si/GERK/documents/${sourceRar}
fi

if [ ! -f ${sourceRar} ]; then
    echo "Soure file ${sourceRar} is missing. Failed to download?"
    exit 1
fi

#----- extract: -------
sourceFolder="RABA_${dateCompact}"
rm -rf ${sourceFolder}
mkdir $sourceFolder
cd ${sourceFolder}
unrar x ../$sourceRar
cd ..

epsgName="RABA_${dateCompact}_EPSG4326"
rm -rf "${epsgName}"
ogr2ogr -s_srs "EPSG:3794" -t_srs "EPSG:4326" ${epsgName} ${sourceFolder} -nln ${epsgName} -progress
rm -rf "${sourceFolder}"

targetFolder="RabaSplits_latest_EPSG4326"

./makeSplitRange.sh 1 3640 ${yyyy} ${mm} ${dd} ${targetFolder}

rm -rf ${epsgName}

#ln -s /osm/raba/RabaSplitForOSM/$targetFolder /osm/raba/raba.openstreetmap.si/RabaSplits_latest_EPSG4326

echo "Finished on $(date)"
