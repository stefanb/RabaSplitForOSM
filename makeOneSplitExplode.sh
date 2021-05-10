#!/bin/bash
set -e
# set -x

splitId=$1
inputFolder="RABA_${2}${3}${4}_EPSG4326"
outputFolder="${5}"
namePrefix="raba"
splitGrid="newSplitID_improve1_EPSG4326"
isoDate="${2}-${3}-${4}"

echo -n "START:	"
date -u +"%Y-%m-%dT%H:%M:%SZ"
echo Making split ${splitId} from ${inputFolder} to folder ${outputFolder}:

echo -n "  Preemptive cleanup..."
rm -rf ${outputFolder}/${namePrefix}${splitId}area
rm -rf ${outputFolder}/${namePrefix}${splitId}spat
rm -rf ${outputFolder}/${namePrefix}${splitId}
rm -rf ${outputFolder}/${namePrefix}${splitId}diss
rm -rf ${outputFolder}/${namePrefix}${splitId}dissJosm
echo "  done."

# extract a shapefile split from large shapefile
echo "  Clipping split ${splitId}:"
#5-step: area from grid, get extent, enlarge extent slightly, fast clip wit -spat option, then exact clip
#1. get split area
echo -n "    Getting split ${splitId} area..."
ogr2ogr -where "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId}area ${splitGrid}/ -nln ${namePrefix}${splitId}area
echo "  done."

#2. determine extent
#$ ogrinfo -al -so splits/split36 | grep Extent
#Extent: (4616000.000024, 2492999.999501) - (4619000.000024, 2494999.999502)
extent_raw=$(ogrinfo -al -so ${outputFolder}/${namePrefix}${splitId}area | grep Extent)
echo "    Split extent_raw value is: ${extent_raw}"

#$ echo -n "Extent: (4616000.000024, 2492999.999501) - (4619000.000024, 2494999.999502)" | grep -o '[\.0-9]*' | tr "\\n" " "
#extent=$(echo -n $extent_raw | grep -o '[\.0-9]*' | tr "\\n" " ")

#3. enlarge extent slightly to accomodate for rounding errors:
extent=$(echo -n $extent_raw | grep -o '[\.0-9]*' | tr "\\n" " "  | awk '{print $1-0.0001 " " $2-0.0001 " " $3+0.0001 " " $4+0.0001}' | tr "\\n" " ")

#4. rough clip by extent
echo -n "    Rough clipping by slightly larger extent: ${extent}..."
#ogr2ogr -progress -clipsrc spat_extent splits/split36spat RABA_20140911_EPSG3035/ -nln ${namePrefix}${splitId}spat -spat 4616000.000024 2492999.999501 4619000.000024 2494999.999502
ogr2ogr -clipsrc spat_extent ${outputFolder}/${namePrefix}${splitId}spat ${inputFolder}/ -nln ${namePrefix}${splitId}spat -spat ${extent}
echo "  done."

#5. exact clip
echo -n "    Exact clip split${splitId}spat via split${splitId}area: "
ogr2ogr -progress -clipsrc ${outputFolder}/${namePrefix}${splitId}area -clipsrclayer ${namePrefix}${splitId}area -clipsrcwhere "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId} ${outputFolder}/${namePrefix}${splitId}spat -nln ${namePrefix}${splitId}


# dissolve a split
echo -n "  Dissolving split ${splitId}..."
# http://gis.stackexchange.com/questions/85028/dissolve-aggregate-polygons-with-ogr2ogr-or-gpc
ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite \
 -sql "SELECT ST_Union(geometry),
		src.RABA_ID,
		'RABA-KGZ' as source,
		'${isoDate}' as SOURCEDATE,
		sif.natural,
		sif.landuse,
		sif.crop,
		sif.trees,
		sif.wetland
	FROM '${namePrefix}${splitId}' AS src
		LEFT JOIN 'SIF_RABA.csv'.SIF_RABA AS sif ON cast(src.RABA_ID as text)=sif.RABA_ID
	WHERE sif.IMPORT = 'YES'
	GROUP BY src.RABA_ID" \
 -nln ${namePrefix}${splitId}diss -explodecollections
echo "  done."

echo -n "  Fixing field names for JOSM in split ${splitId}..."
cp --recursive ${outputFolder}/${namePrefix}${splitId}diss ${outputFolder}/${namePrefix}${splitId}dissJosm

mv ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss.dbf ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf
bbe -e "s/RABA_ID/raba:id/" -e "s/SOURCEDATE\x00/source:date/" ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf -o ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss.dbf
rm ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf
echo "  done."

echo "  Zipping:"
cd ${outputFolder}/${namePrefix}${splitId}dissJosm/
zip ../${namePrefix}${splitId}dissJosm.zip *
cd ..
fileInfo=`ls -lah ${namePrefix}${splitId}dissJosm.zip |cut -d' ' -f5-`
echo "  Got file: ${fileInfo}"
echo ${fileInfo} > ${namePrefix}${splitId}dissJosmInfo.txt
cd ..

echo -n "  Cleanup..."
rm -r ${outputFolder}/${namePrefix}${splitId}area
rm -r ${outputFolder}/${namePrefix}${splitId}spat
rm -r ${outputFolder}/${namePrefix}${splitId}
rm -r ${outputFolder}/${namePrefix}${splitId}diss
rm -r ${outputFolder}/${namePrefix}${splitId}dissJosm
echo "  done."

echo Done with split ${splitId}.
echo -n "END:	"
date -u +"%Y-%m-%dT%H:%M:%SZ"
