Raba split for OpenStreetMap import
===================================

These scripts prepare the RABA-KGZ source shapefile into form suitable for
import into OpenStreetMap, by performing these actions:
* Re-project source from Gauss-Krueger/D48 into EPSG:4326 (aka ETRS89, WGS84) using [GeoCoordinateConverter](https://github.com/mrihtar/GeoCoordinateConverter)
* Split the reprojected shapefile into smaller 2x3 km sections as defined in [split grid](newSplitID_improve1_EPSG4326), manage-able for import
* Dissolve (join) neighboring polygons of same type into one
* Tag the splits with OpenStreetMap tags directly as defined in [mapping table](SIF_RABA.csv).
* Hack the produced shapefile to include 11-character fieldname and special character (namely "[source:date](https://wiki.openstreetmap.org/wiki/Key:source:date)" and "[raba:id](https://wiki.openstreetmap.org/wiki/Key:raba:id)" OSM tags)
* Zip all the parts of shapefile for import using JOSM with opengeodata plugin
* Optional: use JOSM remote control via dedicated [raba.openstreetmap.si](http://raba.openstreetmap.si) website ([source in git](https://github.com/openstreetmap-si/raba.openstreetmap.si)) to perform import

### Requirements
* Source shapefile from http://rkg.gov.si/GERK/, eg. [RABA_2015_10_31.RAR](http://rkg.gov.si/GERK/documents/RABA_2015_10_31.RAR) (600 MB)
* [GeoCoordinateConverter](https://github.com/mrihtar/GeoCoordinateConverter) (http://geocoordinateconverter.tk)
* [ogr2ogr](http://www.gdal.org/ogr2ogr.html) from [GDAL suite](http://www.gdal.org/index.html)
* [bbe](https://tracker.debian.org/pkg/bbe)

### Usage
Basic:

    $ ./makeSplitRange.sh 1 3640

Starting 4 processes in parallel:

    $ nohup ./makeSplitRange.sh 1 999 &
    $ nohup ./makeSplitRange.sh 1000 1999 &
    $ nohup ./makeSplitRange.sh 2000 2999 &
    $ nohup ./makeSplitRange.sh 3000 3640 &
(observe the generated nohup.out to see the progress)

### More info
* [Slovenia Landcover Import - RABA-KGZ](https://wiki.openstreetmap.org/wiki/Slovenia_Landcover_Import_-_RABA-KGZ) wiki page
* Forum: http://forum.openstreetmap.org/viewtopic.php?pid=449111

### Credits
* OpenStreetMap local and global community
* Matjaž Rihtar (author of [GeoCoordinateConverter](http://geocoordinateconverter.tk))
* Štefan Baebler (author of RabaSplitForOSM and [raba.openstreetmap.si](http://raba.openstreetmap.si))
* [Ministry of Agriculture, Forestry and Food](http://www.mkgp.gov.si) (authors of RABA source data)
* [FOSSGIS](http://wiki.openstreetmap.org/wiki/FOSSGIS) (hosting via their sponsor Strato)
