#!/bin/bash
#####################################################################
echo "------------------------------------------------"
echo "JFNMOC_${model/fnmoc_/}_GEMPAK - FNMOC WAVE gempak"
echo "------------------------------------------------"
echo "History: JAN 2015 - FNMOC WAVE gempak"
#####################################################################
set -x
cd $DATA

##########################################
#
# START FLOW OF CONTROL
#
# 1) Get the Date from /com/date
# 2) Extract FNMOC WAVE data from /dcom holding directory.
# 3) Form GRIB1 fields from input GRIB files.
# 4) Use COPYGB to form final grid.
# 5) Convert GRIB1 output to GRIB2
#
#########################################

########################################
set -x
msg="HAS BEGUN!"
postmsg "$jlogfile" "$msg"
########################################

set +x
echo " "
echo "#########################################"
echo " Check to see if all FNMOC WAVE data is      "
echo " available in /dcom                      "
echo "#########################################"
echo " "
set -x

INPUT_DIR="${dcom}/${PDY}/wgrbbul/${model}/"
date_cycle="${PDY}${cyc}"
grib_wd="${DATA}/grib"; mkdir -p $grib_wd
gempak_wd="${DATA}/gempak"; mkdir -p $gempak_wd
gtbl_dir="${HOMEfnmoc_wave}/gempak/tables"
typ1="US058GOCN-GR1mdl.0110_0240"
grb_alrt=FNMOC_WAVE_GRIB
gmk_alrt=FNMOC_WAVE_GEMPAK

if [ ! -z ${gtbl_dir} ]; then
    cd ${gempak_wd}
    cp ${gtbl_dir}/* .
else
    echo "No GEMPAK table present."
    export err=2; err_chk
fi

if [ "$SENDCOM" = YES ]; then
    cnt=0
    # Process the files
    for hour in 000 003 006 009 012 015 018 021 024 030 036 042 048 054 060 066 072 084 096 108 120 132 144; do
        while [[ "0$(ls ${INPUT_DIR}/${typ1}_${hour}00F0RL${PDY}${cyc}_*)" == "0" ]] && [[ "${cnt}" != "12" ]];
        do
            echo "Sleeping for 5 minutes, missing DCOM data, ${INPUT_DIR}/${typ1}_${hour}00F0RL${PDY}${cyc}_*"
            sleep 300
            ((cnt++))
        done
        if [[ "${cnt}" == "12" ]];
        then
            set +xa
            echo "${INPUT_DIR}/${typ1}_${hour}00F0RL${PDY}${cyc}_*" >> ${DATA}/missing_files
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "MISSING FNMOC_WAVE DATA: "
            cat ${DATA}/missing_files
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            set -xa
            $DATA/err_exit
        else
            cat ${INPUT_DIR}/${typ1}_${hour}00F0RL${PDY}${cyc}_* >> ${grib_wd}/${model/fnmoc_/}_${PDY}${cyc}f${hour}
            if [ -f  ${grib_wd}/${model/fnmoc_/}_${PDY}${cyc}f${hour} ]; then
                echo "Overwriting ${GRIBOUT}/${model/fnmoc_/}_${PDY}${cyc}f${hour}"
                cp -rp ${grib_wd}/${model/fnmoc_/}_${PDY}${cyc}f${hour} ${GRIBOUT}/${model/fnmoc_/}_${PDY}${cyc}f${hour}
		export err=$?; err_chk
                if [ "$SENDDBN" = YES ]; then
                    ${DBNROOT}/bin/dbn_alert MODEL ${grb_alrt} $jobid ${GRIBOUT}/${model/fnmoc_/}_${PDY}${cyc}f${hour}
                fi
            else
                echo "-------- ${grib_wd}/${model/fnmoc_/}_${PDY}${cyc}f${hour} DOES NOT EXIST. ---------"
            fi
            
            ${USHfnmoc_wave}/decode_model.sh ${GRIBOUT}/${model/fnmoc_/}_${PDY}${cyc}f${hour} ${COMOUT} ${gmk_alrt}
	    export err=$?; err_chk
        fi
    done
fi

#####################################################################
# GOOD RUN
set +x
echo "**************job ${job} COMPLETED NORMALLY ON WCOSS2"
echo "**************job ${job} COMPLETED NORMALLY ON WCOSS2"
echo "**************job ${job} COMPLETED NORMALLY ON WCOSS2"
set -x
#####################################################################

msg="HAS COMPLETED NORMALLY!"
echo $msg
postmsg "$jlogfile" "$msg"

############## END OF SCRIPT #######################
