#!/bin/bash

ORIG=mapcycle.txt.orig
NEW=mapcycle.txt.new
ALL=mapcycle.txt.all

# create mapcycle for new maps
echo -n "" > ${NEW}
for f in `ls ut4_*`; do 
	echo `basename $f .pk3` >> ${NEW}
done

# create mapcycle for all maps
#echo -n "" > ${ALL}
cat ${ORIG} > ${ALL}
cat ${NEW}  >> ${ALL}


