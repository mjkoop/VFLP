#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . distribute-collections.sh
#
# Description: Distributes collections in the file ./todo.temp to queues via the ligand-collections/current files. 
# The file has to be adjusted to the current needs.
#
# Revision history:
# 2016-01-02  Created (version 6.2)
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if first argument is -h
if [ "${1}" = "-h" ]; then
usage="Usage: . distribute_collections.sh"
    echo "${usage}"
    return
fi

# Variables
jobline_no=301
queue_no_3=1
queue_no_2=1

# Loop for each collection
for collection_line in $(seq 1 $(wc -l todo.temp | awk -F ' ' '{print $1}')); do
	sed -n "${collection_line}p" todo.temp > ../workflow/ligand-collections/current/${jobline_no}-${queue_no_2}-${queue_no_3}
	if [ "$queue_no_3" -eq "24" ]; then
		queue_no_3=1
	        if [ "$queue_no_2" -eq "10" ]; then
	                jobline_no=$((jobline_no + 1))
        	        queue_no_2=1
	        else
			queue_no_2=$((queue_no_2 + 1))
		fi

	else 
		queue_no_3=$((queue_no_3 + 1))
	fi
done