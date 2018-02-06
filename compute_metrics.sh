#!/bin/bash
#
# This script extract metrics.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad 2018-01-30

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
# shape analysis
sct_process_segmentation -i ${file_seg} -p shape -ofolder ${PATH_RESULTS}"shape_analysis/"${subject}
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
# compute WM CSA
sct_process_segmentation -i wm_seg.nii.gz -p csa -z 2:7 -ofolder ${PATH_RESULTS}"WM_CSA/" -no-angle 1
# compute GM CSA
sct_process_segmentation -i ${file_gmseg} -p csa -z 2:7 -ofolder ${PATH_RESULTS}"GM_CSA/" -no-angle 1
cd -

# dwi
# ===========================================================================================
cd dwi
mkdir ${PATH_RESULTS}diffusion
# compute FA in WM
sct_extract_metric -i dti_FA.nii.gz -l 51 -method map -o ${PATH_RESULTS}diffusion/FA_in_WM.xls
# compute FA in dorsal columns
sct_extract_metric -i dti_FA.nii.gz -l 53 -method map -o ${PATH_RESULTS}diffusion/FA_in_DC.xls
# compute FA in lateral funiculi
sct_extract_metric -i dti_FA.nii.gz -l 54 -method map -o ${PATH_RESULTS}diffusion/FA_in_LF.xls
# compute FA in ventral funiculi
sct_extract_metric -i dti_FA.nii.gz -l 55 -method map -o ${PATH_RESULTS}diffusion/FA_in_VF.xls
cd -
