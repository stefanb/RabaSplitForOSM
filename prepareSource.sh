#parameters:
yyyy="2016"
dd="03"
mm="03"
# possible default: http://stackoverflow.com/questions/16835145/how-to-get-last-day-of-last-month-in-unix

#internal variables...
dateSource="${yyyy}_${mm}_${dd}"
dateCompact="${yyyy}${mm}${dd}"

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
if [ ! -d "${sourceFolder}" ]; then
  # Control will enter here if $DIRECTORY doesn't exist
    mkdir $sourceFolder
    cd ${sourceFolder}
    unrar x ../$sourceRar
    cd ..
else
    echo $sourceFolder exists, using it;
    ls -la $sourceFolder
fi


etrsName="RABA_${dateCompact}_ETRS89"
if [ ! -d "${etrsName}" ]; then
  # Control will enter here if $DIRECTORY doesn't exist
    cd $sourceFolder
    ../GeoCoordinateConverter/gk-shp -t 9 -dd RABA_${dateCompact}.shp ${etrsName}.shp
    #../GeoCoordinateConverter/gk-shp -t 9 -dd RABA_20151231.shp RABA_20151231_EPSG4326.shp
    cd ..
    mkdir $etrsName
    mv ${sourceFolder}/${etrsName}.* ${etrsName}
else
    echo $etrsName folder exists, using it;
    ls -la $etrsName
fi

epsgName="RABA_${dateCompact}_EPSG4326"
if [ ! -d "${epsgName}" ]; then
    ogr2ogr -t_srs "EPSG:4326" ${epsgName} ${etrsName} -nln ${epsgName} -progress
else
    echo $epsgName folder exists, using it;
    ls -la $epsgName
fi

targetFolder="RabaSplits_${dateCompact}_EPSG4326"
if [ ! -d "${targetFolder}" ]; then
  # Control will enter here if $DIRECTORY doesn't exist
  #  mkdir RabaSplits_20151231_EPSG4326
    mkdir $targetFolder
    ln -s /osm/raba/$targetFolder /osm/wwwroot/osm.si/$targetFolder
else
     echo Folder $targetFolder already exists, containing:
     ls -la $targetFolder/*
#     rm -r $targetFolder/*
fi

nohup ./makeSplitRange.sh 1 3640 ${yyyy} ${mm} ${dd} &

echo "It is safe to ctrl+break, as it runs in background..."
touch nohup.out
tail -f nohup.out
