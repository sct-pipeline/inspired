#!/bin/bash
#
# This is a wrapper to processing scripts, that loops across subjects.
#
# Usage:
#   ./run_process.sh <script>
#
# Example:
#   ./run_process.sh prepare_data.sh
#
# Note:
#   Make sure to edit the file parameters.sh with the proper list of subjects and variable.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad 2018-01-29


# Load parameters
source parameters.sh

# build syntax for process execution
PATH_PROCESS=`pwd`/$1

# Loop across subjects
for subject in ${SUBJECTS[@]}; do
  # Display stuff
  echo "Processing subject: ${subject}"
  # go to subject folder
  cd ${PATH_DATA}${subject}${SUBFOLDER}
  # create processing folder
  if [ ! -d ${FOLDER_PROC} ]; then
    mkdir ${FOLDER_PROC}
  fi
  # go to processing folder
  cd ${FOLDER_PROC}
  # run process
  $PATH_PROCESS ${subject}
done
