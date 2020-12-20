#!/bin/bash
#
# Process data.
#
# Usage:
#   ./process_data.sh <SUBJECT>
#
# Manual segmentations or labels should be located were the images are
#
# Authors: Julien Cohen-Adad

# The following global variables are retrieved from the caller sct_run_batch
# but could be overwritten by uncommenting the lines below:
# PATH_DATA_PROCESSED="~/data_processed"
# PATH_RESULTS="~/results"
# PATH_LOG="~/log"
# PATH_QC="~/qc"

# Uncomment for full verbose
set -x

# Immediately exit if error
set -e -o pipefail

# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

# Retrieve input params
SUBJECT=$1

# get starting time:
start=`date +%s`


# FUNCTIONS
# ==============================================================================

# Check if manual label already exists. If it does, copy it locally. If it does
# not, perform labeling.
label_if_does_not_exist(){
  local file="$1"
  local file_seg="$2"
  # Update global variable with segmentation file name
  FILELABEL="${file}_labels"
  FILELABELMANUAL="${FILELABEL}-manual.nii.gz"
  echo "Looking for manual label: $FILELABELMANUAL"
  if [[ -e $FILELABELMANUAL ]]; then
    echo "Found! Using manual labels."
    rsync -avzh $FILELABELMANUAL ${FILELABEL}.nii.gz
  else
    echo "Not found. Proceeding with automatic labeling."
    # Generate labeled segmentation
    sct_label_vertebrae -i ${file}.nii.gz -s ${file_seg}.nii.gz -c t2
    # Create label at the C2-C3 and C6-C7 intervertebral discs
    sct_label_utils -i ${file_seg}_labeled_discs.nii.gz -keep 3,7 -o ${FILELABEL}.nii.gz
  fi
}

# Check if manual segmentation already exists. If it does, copy it locally. If
# it does not, perform seg.
segment_if_does_not_exist(){
  local file="$1"
  local contrast="$2"
  # Find contrast
  if [[ $contrast == "dwi" ]]; then
    folder_contrast="dwi"
  else
    folder_contrast="anat"
  fi
  # Update global variable with segmentation file name
  FILESEG="${file}_seg"
  FILESEGMANUAL="${FILESEG}-manual.nii.gz"
  echo
  echo "Looking for manual segmentation: $FILESEGMANUAL"
  if [[ -e $FILESEGMANUAL ]]; then
    echo "Found! Using manual segmentation."
    rsync -avzh $FILESEGMANUAL ${FILESEG}.nii.gz
    sct_qc -i ${file}.nii.gz -s ${FILESEG}.nii.gz -p sct_deepseg_sc -qc ${PATH_QC} -qc-subject ${SUBJECT}
  else
    echo "Not found. Proceeding with automatic segmentation."
    # Segment spinal cord
    sct_deepseg_sc -i ${file}.nii.gz -c $contrast -qc ${PATH_QC} -qc-subject ${SUBJECT}
  fi
}

# Check if manual segmentation already exists. If it does, copy it locally. If
# it does not, perform seg.
segment_gm_if_does_not_exist(){
  local file="$1"
  local contrast="$2"
  # Update global variable with segmentation file name
  FILESEG="${file}_gmseg"
  FILESEGMANUAL="${FILESEG}-manual.nii.gz"
  echo "Looking for manual segmentation: $FILESEGMANUAL"
  if [[ -e $FILESEGMANUAL ]]; then
    echo "Found! Using manual segmentation."
    rsync -avzh $FILESEGMANUAL ${FILESEG}.nii.gz
    sct_qc -i ${file}.nii.gz -s ${FILESEG}.nii.gz -p sct_deepseg_gm -qc ${PATH_QC} -qc-subject ${SUBJECT}
  else
    echo "Not found. Proceeding with automatic segmentation."
    # Segment spinal cord
    sct_deepseg_gm -i ${file}.nii.gz -qc ${PATH_QC} -qc-subject ${SUBJECT}
  fi
}



# SCRIPT STARTS HERE
# ==============================================================================
# Display useful info for the log, such as SCT version, RAM and CPU cores available
sct_check_dependencies -short

# Go to folder where data will be copied and processed
cd $PATH_DATA_PROCESSED
# Copy source images
rsync -avzh $PATH_DATA/$SUBJECT .
# Organize files under folder (specific to INSPIRED project)
cd ${SUBJECT}/bl/cord
mkdir -p processing_sct
cd processing_sct
cp ../*.nii.gz .

# T2 sag
# ------------------------------------------------------------------------------
file_t2="t2_sag"
# Reorient to RPI and resample to 0.8mm iso
sct_image -i ${file_t2}.nii.gz -setorient RPI -o ${file_t2}_RPI.nii.gz
sct_resample -i ${file_t2}_RPI.nii.gz -mm 0.8x0.8x0.8 -o ${file_t2}_RPI_r.nii.gz
file_t2="${file_t2}_RPI_r"
# Segment spinal cord (only if it does not exist)
segment_if_does_not_exist $file_t2 "t2"
file_t2_seg=$FILESEG
# Create vertebral labels
label_if_does_not_exist ${file_t2} ${file_t2_seg}
file_label=$FILELABEL
# Register to PAM50 template
sct_register_to_template -i ${file_t2}.nii.gz -s ${file_t2_seg}.nii.gz -ldisc ${file_label}.nii.gz -c t2 -param step=1,type=seg,algo=centermass:step=2,type=seg,algo=syn,slicewise=1,smooth=0,iter=3 -qc ${PATH_QC} -qc-subject ${SUBJECT}
# Warp template without the white matter atlas (we don't need it at this point)
sct_warp_template -d ${file_t2}.nii.gz -w warp_template2anat.nii.gz -a 0
# Generate QC report to assess vertebral labeling
sct_qc -i ${file_t2}.nii.gz -s label/template/PAM50_levels.nii.gz -p sct_label_vertebrae -qc ${PATH_QC} -qc-subject ${SUBJECT}

# T2 ax
# ------------------------------------------------------------------------------
file_t2_ax="t2_tra"
# Segment spinal cord (only if it does not exist)
segment_if_does_not_exist $file_t2_ax "t2"
file_t2_ax_seg=$FILESEG
# Bring vertebral levels into the native image space
sct_register_multimodal -i label/template/PAM50_levels.nii.gz -d ${file_t2_ax}.nii.gz -x nn -identity 1 -o ${file_t2_ax}_vertlevels.nii.gz
# Compute average cord CSA per slice
sct_process_segmentation -i ${file_t2_ax_seg}.nii.gz -perslice 1 -vertfile ${file_t2_ax}_vertlevels.nii.gz -o ${PATH_RESULTS}/csa-SC_T2.csv -append 1 -qc ${PATH_QC} -qc-subject ${SUBJECT}

# T2s ax
# ------------------------------------------------------------------------------
file_t2s="pd_medic"
# Segment spinal cord (only if it does not exist)
segment_if_does_not_exist $file_t2s "t2s"
file_t2s_seg=$FILESEG
# Bring vertebral levels into the native image space
sct_register_multimodal -i label/template/PAM50_levels.nii.gz -d ${file_t2s}.nii.gz -x nn -identity 1 -o ${file_t2s}_vertlevels.nii.gz
# Segment gray matter (only if it does not exist)
segment_gm_if_does_not_exist $file_t2s "t2s"
file_t2s_gmseg=$FILESEG
# Compute cord and gray matter CSA between C2 and C3 levels
# NB: Here we set -no-angle 1 because we do not want angle correction: it is too
# unstable with GM seg, and t2s data were acquired orthogonal to the cord anyways.
sct_process_segmentation -i ${file_t2s_seg}.nii.gz -angle-corr 0 -vert 2:3 -vertfile ${file_t2s}_vertlevels.nii.gz -o ${PATH_RESULTS}/csa-SC_MEDIC.csv -append 1
sct_process_segmentation -i ${file_t2s_gmseg}.nii.gz -angle-corr 0 -vert 2:3 -vertfile ${file_t2s}_vertlevels.nii.gz -o ${PATH_RESULTS}/csa-GM_MEDIC.csv -append 1

# DWI
# ------------------------------------------------------------------------------
# TODO

# Verify presence of output files and write log file if error
# ------------------------------------------------------------------------------
FILES_TO_CHECK=(
  "${file_t2_ax_seg}.nii.gz"
  "${file_t2s_seg}.nii.gz"
  "${file_t2s_gmseg}.nii.gz"
)
for file in ${FILES_TO_CHECK[@]}; do
  if [[ ! -e $file ]]; then
    echo "${SUBJECT}/${file} does not exist" >> $PATH_LOG/_error_check_output_files.log
  fi
done

# Display useful info for the log
end=`date +%s`
runtime=$((end-start))
echo
echo "~~~"
echo "SCT version: `sct_version`"
echo "Ran on:      `uname -nsr`"
echo "Duration:    $(($runtime / 3600))hrs $((($runtime / 60) % 60))min $(($runtime % 60))sec"
echo "~~~"


# OLD PROCESSING
#
# # t2
# # ===========================================================================================
# cd t2
# # segment cord
# sct_deepseg_sc -i t2.nii.gz -c t2 -qc ${PATH_QC}
# # TODO: add module to consider seg_manual if necessary
# cd ..
#
# # t2s
# # ===========================================================================================
# cd t2s
# # extract first volume
# sct_image -i t2s_all.nii.gz -split t
# # detect spinal cord
# sct_get_centerline -i t2s_all_T0000.nii.gz -c t2s
# # create VOI centered around spinal cord
# sct_create_mask -i t2s_all_T0000.nii.gz -p centerline,t2s_all_T0000_centerline.nii.gz -size 55 -f cylinder -o mask_t2s.nii.gz
# # motion correction across volumes (using VOI for more accuracy)
# sct_fmri_moco -i t2s_all.nii.gz -g 1 -m mask_t2s.nii.gz -x spline
# # average all motion-corrected volumes
# sct_maths -i t2s_all.nii.gz -mean t -o t2s_all_mean.nii.gz
# # segment spinal cord
# sct_deepseg_sc -i t2s_all_moco_mean.nii.gz -c t2s -qc ${PATH_QC}
# # TODO: QC: Adjust cord segmentation if necessary. Save new segmentation as: t2s_all_moco_mean_seg_manual.nii.gz
# # segment spinal cord gray matter
# sct_deepseg_gm -i t2s_all_moco_mean.nii.gz -qc ${PATH_QC}
# # TODO: QC: Adjust GM segmentation if necessary. Save new segmentation as: t2s_all_moco_mean_gmseg_manual.nii.gz
# cd ..
#
# # dwi
# # ===========================================================================================
# cd dwi
# # average DWI data
# sct_dmri_separate_b0_and_dwi -i dmri.nii.gz -bvec bvec.txt -a 1
# # detect cord centerline
# sct_get_centerline -i dmri_dwi_mean.nii.gz -c dwi
# # create VOI centered around spinal cord
# sct_create_mask -i dmri_dwi_mean.nii.gz -p centerline,dmri_dwi_mean_centerline.nii.gz -size 45 -f cylinder -o mask_dmri.nii.gz
# # crop data (for faster processing)
# sct_crop_image -i dmri.nii.gz -m mask_dmri.nii.gz -o dmri_crop.nii.gz
# # motion correction across volumes
# sct_dmri_moco -i dmri_crop.nii.gz -bvec bvec.txt -g 2 -x spline
# # compute DWI
# sct_dmri_compute_dti -i dmri_crop_moco.nii.gz -bvec bvec.txt -bval bval.txt
# # if manual correction exists, select it
# if [ -d "dmri_crop_moco_dwi_mean_seg_manual.nii.gz" ]; then
#   file_seg="dmri_crop_moco_dwi_mean_seg_manual.nii.gz"
# else
#   # segment cord
#   sct_propseg -i dmri_crop_moco_dwi_mean.nii.gz -c dwi -qc ${PATH_QC}
#   file_seg="dmri_crop_moco_dwi_mean_seg.nii.gz"
# fi
# # create label at C2-C3 disc, knowing that the FOV is centered at C2-C3 disc
# sct_label_utils -i ${file_seg} -create-seg -1,3
# # Register to template
# sct_register_to_template -i dmri_crop_moco_dwi_mean.nii.gz -s ${file_seg} -ldisc labels.nii.gz -c t1 -ref subject -param step=1,type=seg,algo=centermass:step=2,type=seg,algo=bsplinesyn,metric=MeanSquares,smooth=0,iter=3,gradStep=1 -qc ${PATH_QC}
# # rename warping field for clarity
# mv warp_template2anat.nii.gz warp_template2dmri.nii.gz
# # warp template
# sct_warp_template -d dmri_crop_moco_dwi_mean.nii.gz -w warp_template2dmri.nii.gz -qc ${PATH_QC}
# # QC
# # fslview dwi_moco_mean.nii.gz -b 0,200 -l Greyscale -t 1 label/template/PAM50_wm.nii.gz -l Blue-Lightblue -b 0.4,1 -t 0.5 &
# cd -
