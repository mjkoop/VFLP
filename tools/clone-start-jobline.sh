#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . clone-start-jobline.sh start_jobline_no end_jobline_no file_to_clone submit_mode
# folders_to_reset partition/queue [delay_time_in_seconds] [quiet]
#
# Description: Creates many copies of a template job file.
#
# Option: submit_mode
#    Possible values: 
#        submit.sh: job is submitted to the batch system.
#        anything else: no job is submitted to the batch system. 
#
# Option: folders_to_reset
#    Possible values: 
#        Are the possible values for the folders_to_reset option of the reset-folders.sh script.
#        Anything else: no resetting of folders
#
# Option: quiet (optional)
#    Possible values: 
#        quiet: No information is displayed on the screen.
#
# Option: delay_time_in_seconds
#    Possible values: Any nonnegative integer
#
# Revision history:
# 2015-12-28  Import of file from JANINA version 2.2 and adaption to STELLAR version 6.1
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if the first argument is -h
usage="Usage: . clone-start-jobline.sh start_jobline_no end_jobline_no file_to_clone submit_mode folders_to_reset partition/queue delay_time_in_seconds [quiet]"
if [ "${1}" = "-h" ]; then
    echo "${usage}"
    return
fi

# Variables
partition=${6}
delay_time=${7}

# Getting the batchsystem type
line=$(grep -m 1 batchsystem ../workflow/control/all.ctrl)
batchsystem="${line/batchsystem=}"

# Cleaning up if specified
cd slave
. reset-folders.sh ${5}
cd ..

# Duplicating the main template job file and modifying the duplicates
for i in $(seq ${1} ${2}); do
    cp ${3} ../workflow/job-files/main/${i}.job
    if [ "${batchsystem}" = "SLURM" ]; then
        sed -i "s/j-1.1/j-${i}.1/g" ../workflow/job-files/main/${i}.job
        sed -i "s/1.1_/${i}.1_/g" ../workflow/job-files/main/${i}.job
        sed -i "s/--partition=.*/--partition=${partition}/g" ../workflow/job-files/main/${i}.job
    elif [ "${batchsystem}" = "MT" ]; then
        sed -i "s/j-1.1/j-${i}.1/g" ../workflow/job-files/main/${i}.job
        sed -i "s/1.1_/${i}.1_/g" ../workflow/job-files/main/${i}.job
        sed -i "s/#PBS -q .*/#PBS -q ${partition}/g" ../workflow/job-files/main/${i}.job
    fi
done

# Submitting the job files
if [[ "${4}" = "submit" ]]; then
    cd slave
    for i in $(seq ${1} ${2}); do
        . submit.sh ../workflow/job-files/main/${i}.job ${partition}
        if [ ! "${i}" = "${2}" ]; then
            sleep ${delay_time}
        fi
    done
    cd ..
fi

# Displaying some information
if [[ ! "$*" = *"quiet"* ]]; then
    echo "The jobs were cloned."
    echo
fi