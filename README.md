# INSPIRED

Spinal cord analysis scripts based on SCT for the INSPIRED project.

## File structure

~~~
PATH_DATA
  |- 001/
  |- 002/
  |- 003/
     |- bl/
        |- brain/
        |- cord/
           |- dwi.nii.gz + bvals/bvecs
           |- t1_sag.nii.gz
           |- t2_sag.nii.gz
           |- t2_tra.nii.gz  # Always centered at the compression site
           |- pd_medic.nii.gz  # Always centered at C2-C3
           |- processing_sct/
              |- t2/  # processing of t2_tra
              |- t2s/  # processing of pd_medic
              |- dwi/  # processing of dwi
~~~


## Dependencies

This pipeline has been tested on [SCT v5.0.1](https://github.com/neuropoly/spinalcordtoolbox/releases).


## How to run

- Download (or `git clone`) this repository:
  ~~~
  git clone git@github.com:sct-pipeline/inspired.git
  ~~~

- Run the script:
  ~~~
  sct_run_batch -path-data <PATH_DATA> -script <PATH_TO_INSPIRED>/process_data.sh -subject-prefix "" -path-output <PATH_OUTPUT> -job -1
  ~~~

- After the pipeline finishes, inspect the quality control (QC) report:
  ~~~
  open <PATH_OUTPUT>/qc/index.html
  ~~~

  Fix the labels and segmentations (see section below), then re-run the pipeline.


## Quality control (QC) and manual correction

### Disc labeling

In the QC report, in the search box, enter "label_vert". This will displays only
processes related to `sct_label_vertebrae`.

If you spot an issue with a subject, run the following command:
~~~
sct_label_utils -i <PATH_OUTPUT>/data_processed/<SUBJECT>bl/cord/processing_sct/t2_sag_RPI_r.nii.gz -create-viewer 3,7 -m "Click at the posterior tip of intervertebral discs C2/C3 and C6/C7." -o <PATH_DATA>/<SUBJECT>bl/cord/t2_sag_RPI_r_labels-manual.nii.gz
~~~

The command above will create the manual labels directly in the source dataset
indicated by path `<PATH_DATA>`, so you don't need to further copy the created
label.

### Cord segmentation

> ⚠️ All manual corrections need to be copied in the original dataset, so they
can be used when re-running the pipeline.

 open the file `t2_sag.nii.gz` with an
image editor (e.g., FSLeyes, ITKsnap)


## License

The MIT License (MIT)

Copyright (c) 2018 Polytechnique Montreal, Université de Montréal

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
