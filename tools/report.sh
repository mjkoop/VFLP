#!/bin/bash
# ---------------------------------------------------------------------------
#
# Usage: . report.sh workflow-status-mode
#
# Description: Display current information about the status of the workflow. 
#
# Option: workflow-status-mode
#    Possible values: 
#        w0: Display no ligand information
#        w1: Display the standard amount of ligand information
#        w2: Display all information available for the ligands
#
# Revision history:
# 2015-12-05  Created (version 1.2)
# 2015-12-16  Adaption to version 2.1
# 2016-07-16  Various improvements
#
# ---------------------------------------------------------------------------

# Displaying help if first argument is -h
if [ "${1}" = "-h" ]; then
usage="Usage: . report.sh workflow-status-mode"
    echo "${usage}"
    return
fi

# Determining the workflow controlfile to use for this jobline
if [ -f ../workflow/control/${jobline_no}.ctrl ]; then
    export controlfile="../workflow/control/${jobline_no}.ctrl"
else
    export controlfile="../workflow/control/all.ctrl"
fi

# Variables
line=$(cat ${controlfile} | grep "collection_folder=" | sed 's/\/$//g')
collection_folder=${line/"collection_folder="}

# Getting the batchsystem type
line=$(grep -m 1 batchsystem ../workflow/control/all.ctrl)
batchsystem="${line/batchsystem=}"

# Setting the target output file format
line=$(cat ${controlfile} | grep "targetformat=")
targetformat=${line/"targetformat="}
targetformat=${targetformat// /}

# Displaying the variables
echo
echo "                                    ***    Status Report    ***                                 "
echo "================================================================================================"
echo
echo "  Joblines "
echo "------------"
if [ "${batchsystem}" = "SLURM" ]; then
    echo "Number of joblines in the batch system: $(squeue -l | grep $USER | grep "j-*" | wc -l)"
fi
if [ "${batchsystem}" = "SLURM" ]; then
    echo "Number of joblines in the batch system currently running: $(squeue -l | grep $USER | grep "j\-" | grep -i "RUNNING" | wc -l)"
elif  [ "${batchsystem}" = "MT" ]; then
    echo "Number of joblines in the batch system currently running: $(squeue -l | grep $USER | grep -i "RUNNING" | wc -l)"
fi
echo "Number of collections which are currently assigend to more than one queue: $(cat ../workflow/ligand-collections/current/* 2>/dev/null | sort | uniq -c | grep " [2-9] " | wc -l)"
echo
echo "  Collections "
echo "---------------"
echo "Total number of ligand collections: $(wc -l  ../workflow/ligand-collections/var/todo.original | awk -F ' ' '{print $1}')"
echo "Number of ligand collections completed: $(cat ../workflow/ligand-collections/done/* 2>/dev/null | wc -l)"
echo "Number of ligand collections currently processing: $(cat ../workflow/ligand-collections/current/* 2>/dev/null | grep -v '^\s*$' | wc -l)"
echo "Number of ligand collections todo: $(cat ../workflow/ligand-collections/todo/* 2>/dev/null | wc -l)"
echo

if [[ "$1" = "w1" || "$1" = "w2" ]]; then
    echo "  Ligands "
    echo "-----------"    
    
    if [[ "$1" = "w2" ]]; then
        ligands_total=0
        for i in $(cat ../workflow/ligand-collections/var/todo.original); do
            ligands_total=$((${ligands_total} + $(cat ${collection_folder}.length/${i/.${targetformat}.gz.tar}) )) 2>/dev/null
        done
        echo "Total number of ligands: ${ligands_total}"
    fi

    ligands_done=0
    for i in ../workflow/ligand-collections/ligand-lists/*.status*; do
        ligands_done=$((${ligands_done} + $(wc -l ${i/.temp}* | awk -F ' ' '{print $1}' 2>/dev/null) )) 2>/dev/null
    done
    echo "Number of ligands started: ${ligands_done}"

    ligands_failed=0
    for i in ../workflow/ligand-collections/ligand-lists/*.status*; do
        ligands_failed=$((${ligands_failed} + $(grep -c "failed" ${i/.temp}* 2>/dev/null) )) 2>/dev/null
    done
    echo "Number of ligands completed successfully: ${ligands_completed}"

    ligands_processing=0
    for i in ../workflow/ligand-collections/ligand-lists/*.status*; do
        ligands_processing=$((${ligands_processing} + $(grep -c "processing" ${i/.temp}* 2>/dev/null) )) 2>/dev/null
    done
    echo "Number of ligands in state processing: ${ligands_processing}"

    ligands_completed=0
    for i in ../workflow/ligand-collections/ligand-lists/*.status*; do
        ligands_completed=$((${ligands_completed} + $(grep -c "completed" ${i/.temp}* 2>/dev/null) )) 2>/dev/null
    done
    echo "Number of ligands failed: ${ligands_failed}"
    echo
fi
echo