#!/bin/bash
#
# This script extracts metrics.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad

# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

subject=${1}

# t2
# ===========================================================================================
cd t2
# if manual segmentation exists, select it
if [ -d "t2_seg_manual.nii.gz" ]; then
  file_seg="t2_seg_manual.nii.gz"
else
  file_seg="t2_seg.nii.gz"
fi
shape analysis at the site of lesion
sct_process_segmentation -i ${file_seg} -p shape -o ${PATH_RESULTS}"/shape_${subject}.csv"
cd -

# t2s
# ===========================================================================================
cd t2s
# if manual cord segmentation exists, select it
if [ -d "t2s_all_moco_mean_seg_manual.nii.gz" ]; then
  file_seg="t2s_all_moco_mean_seg_manual.nii.gz"
else
  file_seg="t2s_all_moco_mean_seg.nii.gz"
fi
# if manual segmentation exists, select it
if [ -d "t2s_all_moco_mean_gmseg_manual.nii.gz" ]; then
  file_gmseg="t2s_all_moco_mean_gmseg_manual.nii.gz"
else
  file_gmseg="t2s_all_moco_mean_gmseg.nii.gz"
fi
# subtract cord and GM seg to get WM seg
sct_maths -i ${file_seg} -sub ${file_gmseg} -o wm_seg.nii.gz
# compute WM and GM CSA
sct_process_segmentation -i wm_seg.nii.gz -p csa -z 2:7 -no-angle 1 -o ${PATH_RESULTS}/"csa_wm.csv" -append 1
sct_process_segmentation -i ${file_gmseg} -p csa -z 2:7 -no-angle 1 -o ${PATH_RESULTS}/"csa_gm.csv" -append 1
cd -

# dwi
# ===========================================================================================
cd dwi
# compute DTI metrics between C1-C4
sct_extract_metric -i dti_FA.nii.gz -l 51 -vert 1:4 -method map -o ${PATH_RESULTS}/dwi_FA_in_WM.csv -append 1
sct_extract_metric -i dti_FA.nii.gz -l 53 -vert 1:4 -method map -o ${PATH_RESULTS}/dwi_FA_in_DC.csv -append 1
sct_extract_metric -i dti_FA.nii.gz -l 54 -vert 1:4 -method map -o ${PATH_RESULTS}/dwi_FA_in_LF.csv -append 1
sct_extract_metric -i dti_FA.nii.gz -l 55 -vert 1:4 -method map -o ${PATH_RESULTS}/dwi_FA_in_VF.csv -append 1
cd -
