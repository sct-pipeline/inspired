# INSPIRED

Spinal cord analysis scripts based on SCT for the INSPIRED project.

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
           |- t2_tra.nii.gz  # Always centered at the compression site
           |- pd_medic.nii.gz  # Always centered at C2-C3
           |- processing_sct/
              |- t2/  # processing of t2_tra
              |- t2s/  # processing of pd_medic
              |- dwi/  # processing of dwi
~~~

## Dependencies

This pipeline has been tested on [SCT v4.0.0_beta.1](https://github.com/neuropoly/spinalcordtoolbox/releases)

## How to run

- Download (or `git clone`) this repository.
- Go to this repository: `cd inspired`
- Copy the file `parameters_template.sh` and rename it as `parameters.sh`.
- Edit the file `parameters.sh` and modify the variables according to your needs.
- Run process: `./run_process.sh PROCESSING_FILE`
- The following `PROCESSING_FILE` are available:
  - `prepare_data.sh`: Copy and rename files according to the convention above
  - `process_data.sh`: Main batch file to process data
  - `compute_metrics.sh`: Compute qMRI metrics

## License

The MIT License (MIT)

Copyright (c) 2018 Polytechnique Montreal, Université de Montréal

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
