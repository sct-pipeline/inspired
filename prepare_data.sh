#!/bin/bash
#
# This script prepares data: rename and copy to appropriate folders.
#
# NB: add the flag "-x" after "!/bin/bash" for full verbose of commands.
# Julien Cohen-Adad 2019-03-13


# t2
# ==============================================================================
# create folder
if [ ! -d "t2" ]; then
  mkdir t2
fi
cd t2
# copy data
cp ${PATH_DATA}/${1}/${SUBFOLDER}/t2_tra.nii.gz t2.nii.gz
# go back to previous folder
cd -

# t2s
# ==============================================================================
# create folder
if [ ! -d "t2s" ]; then
  mkdir t2s
fi
cd t2s
# copy data
cp ${PATH_DATA}/${1}/${SUBFOLDER}/pd_medic.nii.gz t2s_all.nii.gz
# go back to previous folder
cd -

# dwi
# ==============================================================================
# create folder
if [ ! -d "dwi" ]; then
  mkdir dwi
fi
cd dwi
# copy data
cp ${PATH_DATA}/${1}/${SUBFOLDER}/dwi.nii.gz dmri.nii.gz
cp ${PATH_DATA}/${1}/${SUBFOLDER}/dwi.bvec bvec.txt
cp ${PATH_DATA}/${1}/${SUBFOLDER}/dwi.bval bval.txt
# go back to previous folder
cd -
