#!/bin/bash
splitId=$1
inputFolder="RABA_${2}${3}${4}_EPSG4326"
outputFolder="RabaSplits_${2}${3}${4}_EPSG4326"
namePrefix="raba"
splitGrid="newSplitID_improve1_EPSG4326"
isoDate="${2}-${3}-${4}"

echo -n "START:	"
date -u +"%Y-%m-%dT%H:%M:%SZ"
echo Making split ${splitId} from ${inputFolder} to folder ${outputFolder}:


# extract a shapefile split from large shapefile
echo "  Clipping split ${splitId}:"
#a) single step (clip by area in grid):
# ~/raba $ ogr2ogr -progress -clipsrclayer newSplitID/ -clipsrcwhere "newSplitID=38" split38 RABA_20140911_ETRS/
#ogr2ogr -progress -clipsrclayer newSplitID/ -clipsrcwhere "newSplitID=38" split38 RABA_20140911_ETRS/ -nln split38
#ogr2ogr -progress -clipsrc newSplitID-SLO -clipsrclayer newSplitID -clipsrcwhere "newSplitID=38" split38 RABA_20140911_EPSG3035/ -nln split38
#ogr2ogr -progress -clipsrc newSplitID_improve1_EPSG3035/ -clipsrclayer newSplitID_improve1_EPSG3035 -clipsrcwhere "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId} RABA_20140911_EPSG3035/ -nln ${namePrefix}${splitId}
#---

#b) 2-step (area from grid + clip):
#ogr2ogr -progress  -where "newSplitID=38" split38area newSplitID/ -nln split38area
#ogr2ogr -progress  -where "newSplitID=${splitId}" ${namePrefix}${splitId}area newSplitID/ -nln ${namePrefix}${splitId}area

#ogr2ogr -progress -clipsrclayer newSplitID/ -clipsrcwhere "newSplitID=${splitId}" ${namePrefix}${splitId} RABA_20140911_ETRS/ -nln ${namePrefix}${splitId}
#ogr2ogr -progress -clipsrclayer split38area/ -clipsrclayer split38area split38 RABA_20140911_ETRS/ -nln split38
#ogr2ogr -progress -clipsrclayer ${namePrefix}${splitId}area/ ${namePrefix}${splitId} RABA_20140911_ETRS/ -nln ${namePrefix}${splitId}

#c) 3-step: area from grid, get extent, fast clip wit -spat option, then exact clip
#get split area
echo -n "    Getting split ${splitId} area..."
#ogr2ogr -where "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId}area newSplitID/ -nln ${namePrefix}${splitId}area
ogr2ogr -where "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId}area ${splitGrid}/ -nln ${namePrefix}${splitId}area
echo "  done."

#determine extent
#$ ogrinfo -al -so splits/split36 | grep Extent
#Extent: (4616000.000024, 2492999.999501) - (4619000.000024, 2494999.999502)
extent_raw=$(ogrinfo -al -so ${outputFolder}/${namePrefix}${splitId}area | grep Extent)
echo "    Split extent_raw value is: ${extent_raw}"

#$ echo -n "Extent: (4616000.000024, 2492999.999501) - (4619000.000024, 2494999.999502)" | grep -o '[\.0-9]*' | tr "\\n" " "
#extent=$(echo -n $extent_raw | grep -o '[\.0-9]*' | tr "\\n" " ")
# enlarge extent slightly to accomodate for rounding errors:
extent=$(echo -n $extent_raw | grep -o '[\.0-9]*' | tr "\\n" " "  | awk '{print $1-0.0001 " " $2-0.0001 " " $3+0.0001 " " $4+0.0001}' | tr "\\n" " ")
#echo "    Determined extent: ${extent}"


#rough clip by extent
echo -n "    Rough clipping by slightly larger extent: ${extent}..."
#ogr2ogr -progress -clipsrc spat_extent splits/split36spat RABA_20140911_EPSG3035/ -nln ${namePrefix}${splitId}spat -spat 4616000.000024 2492999.999501 4619000.000024 2494999.999502
ogr2ogr -clipsrc spat_extent ${outputFolder}/${namePrefix}${splitId}spat ${inputFolder}/ -nln ${namePrefix}${splitId}spat -spat ${extent}
echo "  done."

#exact clip
echo -n "    Exact clip split${splitId}spat via split${splitId}area: "
ogr2ogr -progress -clipsrc ${outputFolder}/${namePrefix}${splitId}area -clipsrclayer ${namePrefix}${splitId}area -clipsrcwhere "newSplitID=${splitId}" ${outputFolder}/${namePrefix}${splitId} ${outputFolder}/${namePrefix}${splitId}spat -nln ${namePrefix}${splitId}


# dissolve a split
echo -n "  Dissolving split ${splitId}..."
# http://gis.stackexchange.com/questions/85028/dissolve-aggregate-polygons-with-ogr2ogr-or-gpc
#ogr2ogr output.shp input.shp -dialect sqlite -sql "SELECT ST_Union(geometry), dissolve_field FROM input GROUP BY dissolve_field"
#ogr2ogr split7diss.shp ./RABA/originalnisloji/7/7.shp -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID FROM '7' GROUP BY RABA_ID"
#ogr2ogr ${namePrefix}${splitId}diss.shp ./RABA/originalnisloji/${splitId}/${splitId}.shp -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID FROM '${namePrefix}${splitId}' GROUP BY RABA_ID"
#ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID  FROM '${namePrefix}${splitId}' GROUP BY RABA_ID" -nln ${namePrefix}${splitId}diss
#ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID, 'RABA-KGZ' as source, 'date is parsed wrong by JOSM' as fixme, SOURCEDATE, natural, landuse, crop, trees  FROM '${namePrefix}${splitId}' GROUP BY RABA_ID" -nln ${namePrefix}${splitId}diss
#ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID, 'RABA-KGZ' as source, '2015-01-13' as SOURCEDATE, natural, landuse, crop, trees  FROM '${namePrefix}${splitId}' GROUP BY RABA_ID" -nln ${namePrefix}${splitId}diss
#ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID, 'RABA-KGZ' as source, '2015-03-31' as SOURCEDATE, natural, landuse, crop, trees, wetland  FROM '${namePrefix}${splitId}' GROUP BY RABA_ID" -nln ${namePrefix}${splitId}diss -explodecollections
#ogr2ogr ${outputFolder}/${namePrefix}${splitId}diss/ ${outputFolder}/${namePrefix}${splitId}/ -dialect sqlite -sql "SELECT ST_Union(geometry), RABA_ID, 'RABA-KGZ' as source, SOURCEDATE, natural, landuse, crop, trees, wetland  FROM '${namePrefix}${splitId}' GROUP BY RABA_ID" -nln ${namePrefix}${splitId}diss -explodecollections
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
#bbe -e "s/RABA_ID/raba:id/" -e "s/SOURCEDATE\x00/source:date/" raba7diss-orig.dbf -o raba7diss.dbf
mv ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss.dbf ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf
bbe -e "s/RABA_ID/raba:id/" -e "s/SOURCEDATE\x00/source:date/" ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf -o ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss.dbf
rm ${outputFolder}/${namePrefix}${splitId}dissJosm/${namePrefix}${splitId}diss-orig.dbf
echo "  done."

#convert to osm using
#echo "  Converting split ${splitId} to .osm:"
#https://github.com/stefanb/ogr2osm-translations/blob/master/raba-kgz.py
#python ogr2osm/ogr2osm.py ~/osmshare/RABA/originalnisloji/7/7.shp -t ~/osmshare/ogr2osm-translations/raba-kgz.py
#python ../ogr2osm/ogr2osm.py ${outputFolder}/${namePrefix}${splitId}diss/${namePrefix}${splitId}diss.shp -t ../ogr2osm-translations/raba-kgz.py

echo "  Zipping:"

# zip the .osm file to .osm.zip
#zip ${outputFolder}/${namePrefix}${splitId}diss.osm.zip ${namePrefix}${splitId}diss.osm
#mv ${namePrefix}${splitId}diss.osm ${outputFolder}/${namePrefix}${splitId}diss.osm

#cd ${outputFolder}/${namePrefix}${splitId}diss/
#zip ../${namePrefix}${splitId}diss.zip *
#cd ..
#ls -la ${namePrefix}${splitId}diss.zip
#cd ..

cd ${outputFolder}/${namePrefix}${splitId}dissJosm/
zip ../${namePrefix}${splitId}dissJosm.zip *
cd ..
fileInfo=`ls -lah ${namePrefix}${splitId}dissJosm.zip |cut -d' ' -f5-`
echo "  Got file: ${fileInfo}"
echo ${fileInfo} > ${namePrefix}${splitId}dissJosmInfo.txt
cd ..

#cleanup
echo -n "  Cleanup..."
rm -r ${outputFolder}/${namePrefix}${splitId}area
rm -r ${outputFolder}/${namePrefix}${splitId}spat
rm -r ${outputFolder}/${namePrefix}${splitId}
rm -r ${outputFolder}/${namePrefix}${splitId}diss
rm -r ${outputFolder}/${namePrefix}${splitId}dissJosm
#rm ${outputFolder}/${namePrefix}${splitId}diss.osm
echo "  done."

echo Done with split ${splitId}.
echo -n "END:	"
date -u +"%Y-%m-%dT%H:%M:%SZ"

