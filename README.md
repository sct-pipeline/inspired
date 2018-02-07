# inspiredsct

Spinal cord analysis scripts based on SCT

## File structure

~~~
data
  |- 001/
  |- 002/
  |- 003/
      |- bl/
	  |- brain/
    	  |- cord/
      	      |- dwi.nii.gz + bvals/bvecs
      	      |- t1_sag.nii.gz
      	      |- t2_sag.nii.gz
      	      |- t2_tra.nii.gz
      	      |- pd_medic.nii.gz
      	      |- processing_sct/
      	          |- t2/  # processing of t2_tra 
      	          |- t2s/  # processing of pd_medic
      	          |- dwi/  # processing of dwi
~~~

## Getting started

- Edit parameters.sh according to your needs.
- Prepare data:
  ./run_process.sh prepare_data.sh
- Process data:
  ./run_process.sh process_data.sh
- Compute metrics:
  ./run_process.sh compute_metrics.sh


## SCT version

This pipeline has been tested on SCT v3.1.1:
https://github.com/neuropoly/spinalcordtoolbox/releases/tag/v3.1.1
