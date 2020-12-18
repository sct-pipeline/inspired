# INSPIRED

Spinal cord analysis scripts based on SCT for the INSPIRED project.

## File structure

~~~
PATH_DATASET
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
  sct_run_batch -path-data <PATH_DATASET> -script <PATH_TO_INSPIRED>/process_data.sh -subject-prefix "" -path-output my_results -job -1
  ~~~

- Once the pipeline has ran once, inspect the HTML quality control report:
  ~~~
  open my_results/qc/index.html
  ~~~

- TODO: add QC manual correction procedure


## License

The MIT License (MIT)

Copyright (c) 2018 Polytechnique Montreal, Université de Montréal

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
