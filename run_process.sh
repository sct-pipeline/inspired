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
#   Make sure to edit the file parameters.sh with the proper variables.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad 2019-03-13


# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

# Initialization
unset SUBJECTS
time_start=$(date +%x_%r)

# Load config file
if [ -e "parameters.sh" ]; then
  source parameters.sh
else
  printf "\n${Red}${On_Black}ERROR: The file parameters.sh was not found. You need to create one for this pipeline to work. Please see README.md.${Color_Off}\n\n"
  exit 1
fi

# build syntax for process execution
PATH_PROCESS=`pwd`/$1

# Create results folder
if [ ! -d ${PATH_RESULTS} ]; then
  mkdir ${PATH_RESULTS}
fi

# Loop across subjects
for subject in ${SUBJECTS[@]}; do
  # Display stuff
  echo "Processing subject: ${subject}"
  # go to subject folder
  cd ${PATH_DATA}/${subject}/${SUBFOLDER}
  # create processing folder
  if [ ! -d ${FOLDER_PROC} ]; then
    mkdir ${FOLDER_PROC}
  fi
  # go to processing folder
  cd ${FOLDER_PROC}
  # run process
  $PATH_PROCESS ${subject}
done

# Display stuff
echo "FINISHED :-)"
echo "Started: $time_start"
echo "Ended  : $(date +%x_%r)"
