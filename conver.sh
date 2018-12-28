#!/bin/sh
pngs=($(find -name '*.png'))
for i in ${pngs[@]};do 
name=`echo "$i" | sed 's/^\(.*[^\.png]\).*$/\1/'`;
echo $name;
sed -i -r "s/png/jpg/g" $name'.map';
convert $i $name'.jpg'
rm $i;   
csvtool drop 45 $name'.map' > temp.csv;
mapfile -t lat < <(csvtool col 3 temp.csv);
mapfile -t long < <(csvtool col 4 temp.csv);
rm temp.csv;
gdal_translate -of GTiff -gcp lat[0] long[0] lat[4] long[4] -gcp lat[1] long[1] lat[5] long[5] -gcp lat[2] long[2] lat[6] long[6] -gcp lat[3] long[3] lat[7] long[7]  $name'.jpg' $name'_geo.jpg';
gdalwarp -r near -order 1 -co COMPRESS=NONE -dstalpha $name'_geo.jpg' $name'_geo.tif';
gdal2tiles.py -z 11-18 -w leaflet $name'_geo.tif';
done
