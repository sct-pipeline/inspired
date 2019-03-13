#!/bin/bash
# Environment variables for the INSPIRED study.

# Set every other path relative to this path for convenience
# Do not add "/" at the end. Path should be absolute (i.e. do not use "~")
export PATH_DATA="/Users/julien/data/INSPIRED/20180118/02"
# sub-folder to spinal cord data (do not add "/" at the end)
export SUBFOLDER="bl/cord"

# List of subjects to analyse. Comment this variable if you want to analyze all
# sites in the PATH_DATA folder.
export SUBJECTS=(
	"001"
	# "002"
	# "003"
)

# Processing sub-folder (do not add "/" at the end). Will be created under
# each subject's folder.
export FOLDER_PROC="processing_sct"

# Path to metric results (do not add "/" at the end)
export PATH_RESULTS="${PATH_DATA}/results"

# Path to analysis QC (do not add "/" at the end)
export PATH_QC="${PATH_DATA}/qc"
