#!/bin/bash
#
# Process data. This script should be run within the subject's folder.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad 2019-03-13

# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

# Retrieve input params
# PATH_QC=$1

# t2
# ===========================================================================================
cd t2
# segment cord
sct_deepseg_sc -i t2.nii.gz -c t2 -qc ${PATH_QC}
# TODO: add module to consider seg_manual if necessary
cd ..

# t2s
# ===========================================================================================
cd t2s
# extract first volume
sct_image -i t2s_all.nii.gz -split t
# detect spinal cord
sct_get_centerline -i t2s_all_T0000.nii.gz -c t2s
# create VOI centered around spinal cord
sct_create_mask -i t2s_all_T0000.nii.gz -p centerline,t2s_all_T0000_centerline.nii.gz -size 55 -f cylinder -o mask_t2s.nii.gz
# motion correction across volumes (using VOI for more accuracy)
sct_fmri_moco -i t2s_all.nii.gz -g 1 -m mask_t2s.nii.gz -x spline
# average all motion-corrected volumes
sct_maths -i t2s_all.nii.gz -mean t -o t2s_all_mean.nii.gz
# segment spinal cord
sct_deepseg_sc -i t2s_all_moco_mean.nii.gz -c t2s -qc ${PATH_QC}
# TODO: QC: Adjust cord segmentation if necessary. Save new segmentation as: t2s_all_moco_mean_seg_manual.nii.gz
# segment spinal cord gray matter
sct_deepseg_gm -i t2s_all_moco_mean.nii.gz -qc ${PATH_QC}
# TODO: QC: Adjust GM segmentation if necessary. Save new segmentation as: t2s_all_moco_mean_gmseg_manual.nii.gz
cd ..

# dwi
# ===========================================================================================
cd dwi
# average DWI data
sct_dmri_separate_b0_and_dwi -i dmri.nii.gz -bvec bvec.txt -a 1
# detect cord centerline
sct_get_centerline -i dmri_dwi_mean.nii.gz -c dwi
# create VOI centered around spinal cord
sct_create_mask -i dmri_dwi_mean.nii.gz -p centerline,dmri_dwi_mean_centerline.nii.gz -size 45 -f cylinder -o mask_dmri.nii.gz
# crop data (for faster processing)
sct_crop_image -i dmri.nii.gz -m mask_dmri.nii.gz -o dmri_crop.nii.gz
# motion correction across volumes
sct_dmri_moco -i dmri_crop.nii.gz -bvec bvec.txt -g 2 -x spline
# compute DWI
sct_dmri_compute_dti -i dmri_crop_moco.nii.gz -bvec bvec.txt -bval bval.txt
# if manual correction exists, select it
if [ -d "dmri_crop_moco_dwi_mean_seg_manual.nii.gz" ]; then
  file_seg="dmri_crop_moco_dwi_mean_seg_manual.nii.gz"
else
  # segment cord
  sct_propseg -i dmri_crop_moco_dwi_mean.nii.gz -c dwi -qc ${PATH_QC}
  file_seg="dmri_crop_moco_dwi_mean_seg.nii.gz"
fi
# create label at C2-C3 disc, knowing that the FOV is centered at C2-C3 disc
sct_label_utils -i ${file_seg} -create-seg -1,3
# Register to template
sct_register_to_template -i dmri_crop_moco_dwi_mean.nii.gz -s ${file_seg} -ldisc labels.nii.gz -c t1 -ref subject -param step=1,type=seg,algo=centermass:step=2,type=seg,algo=bsplinesyn,metric=MeanSquares,smooth=0,iter=3,gradStep=1 -qc ${PATH_QC}
# rename warping field for clarity
mv warp_template2anat.nii.gz warp_template2dmri.nii.gz
# warp template
sct_warp_template -d dmri_crop_moco_dwi_mean.nii.gz -w warp_template2dmri.nii.gz -qc ${PATH_QC}
# QC
# fslview dwi_moco_mean.nii.gz -b 0,200 -l Greyscale -t 1 label/template/PAM50_wm.nii.gz -l Blue-Lightblue -b 0.4,1 -t 0.5 &
cd -
