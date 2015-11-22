http://forum.openstreetmap.org/viewtopic.php?pid=449111

$ ogr2ogr -t_srs "EPSG:4326" RABA_20150331_import_EPSG4326 RABA_20150331_84_import -nln RABA_20150331_import_EPSG4326 -progress

$ nohup ./makeSplitRange_20150331_EPSG4326.sh 1 3640 &


forests
$ ogr2ogr RABA_20150331_import_forest_EPSG4326 RABA_20150331_import_EPSG4326 -where "RABA_ID=1420 OR RABA_ID=1800 OR RABA_ID=2000 OR RABA_ID=1500" -nln RABA_20150331_import_forest_EPSG4326 -progress
