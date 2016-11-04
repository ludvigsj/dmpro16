#!/bin/bash

workdir=../vivado-workdir

mkdir -p ${workdir}
## Always regenerate the project file, in case new source files have been added.
./gen_prj.sh > ${workdir}/sim-prj.prj;
