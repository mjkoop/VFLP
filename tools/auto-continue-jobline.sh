#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . auto-continue-jobline.sh first_jobline_no last_jobline_no job_template partition [quiet]
#
# Description: Automatically finds the joblines which are not running and continues the jobline. 
#
# Option: quiet (optional)
#    Possible values: 
#        quiet: No information is displayed on the screen.
#
# Revision history:
# 2015-12-05  Created (version 1.2)
# 2015-12-16  Adaption to version 2.1
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if the first argument is -h
usage="Usage: . auto-continue-jobline.sh.sh first_jobline_no last_jobline_no job_template partition delay_time_in_seconds [quiet]"
if [ "${1}" = "-h" ]; then
    echo "${usage}"
    return
fi

# Removing old files if existens
if [ -f "tmp/jobs-to-continue" ]; then
    rm tmp/jobs-to-continue
fi

# Storing all the jobs which are currently running
sqs > tmp/jobs-all

# Storing all joblines which have to be restarted
for jobline_no in $(seq ${1} ${2}); do 
    if ! grep -q "j-${jobline_no}\."  tmp/jobs-all; then 
        echo ${jobline_no} >> "tmp/jobs-to-continue"
    fi
done

# Variables
k=0
delay_time="${5}"
k_max="$(cat tmp/jobs-to-continue | wc -l)"

# Resetting the collections and continuing the jobs if existent
if [ -f tmp/jobs-to-continue ]; then
    for jobline_no in $(cat tmp/jobs-to-continue); do
        k=$(( k + 1 ))
        cd slave
        . exchange-continue-jobline.sh ${jobline_no} ${jobline_no} ${3} ${4} quiet
        cd ..
        if [ ! "${k}" = "${k_max}" ]; then
            sleep ${delay_time}
        fi
    done
fi

# Removing the temporary files
if [ -f "tmp/jobs-all" ]; then
    rm tmp/jobs-all
fi
if [ -f "tmp/jobs-to-continue" ]; then
    rm tmp/jobs-to-continue
fi

# Displaying some information
if [[ ! "$*" = *"quiet"* ]]; then
    echo "Number of joblines which were continued: ${k}"
    echo
fi