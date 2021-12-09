#!/bin/sh
set -xa
# ***********************************************************************
# decode_model
#
# This script decodes a GRIB message file into a GEMPAK grid file.
#
# decode_model  filename  dest_path  model
#
# Input parameters:
# $1	filename	Full dest_path and file name of GRIB message file
# $2	dest_path	Full dest_path of directory to put GEMPAK file
# $3	model		Model name, if applicable
# $4    table_dir       optional nagrib tables
#
# Log:
# Programmer    	Date       Change Description
# ----------    	----       ------------------
# DWPlummer/NCEP	11/20/00   New
# L.J.Cano              06/14/01   added optional table dir, initially done
#                                  for fnmoc wave model.
# P.O'Reilly		07/17/07   Modified to create GEMPAK file into
#				   temp file, then move to final resting
#				   place when complete
# ***********************************************************************

filename=${1}
dest_path=${2}
model=${3}

echo "`date -u` -- Converting GRIB file $filename to GEMPAK file $gdoutf."

gdoutf="${dest_path}/$(basename $filename)"
tempgdoutf="${DATA}/gempak/$(basename $filename)"
cpyfil=gds
maxgrd=5000
output=T
garea=dset

echo "`date -u` -- Converting GRIB file ${filename} to GEMPAK file ${gdoutf}."

${NAGRIB} << EOF >> nagrib_nc.log
GBFILE=$filename
GDOUTF=$tempgdoutf
CPYFIL=$cpyfil
MAXGRD=$maxgrd
OUTPUT=$output
GAREA=$garea
l
r

ex
EOF

if [ -e $tempgdoutf ]; then
    cp -rp $tempgdoutf $gdoutf
else
    msg="Conversion FAILED for GRIB file $filename to GEMPAK file $gdoutf"
    echo "`date -u` -- $msg"
    ${DATA}/err_exit
fi

if [ "$SENDDBN" = YES ]; then
    $DBNROOT/bin/dbn_alert MODEL $model $jobid $gdoutf
fi

echo "`date -u` -- Conversion complete for GRIB file $filename to GEMPAK file $gdoutf"

exit 0
