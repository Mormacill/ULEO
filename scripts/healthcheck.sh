#!/bin/bash

#Lmod
module --help || exit 1

#EasyBuild
export MODULEPATH=$MODULEPATH:/home/easybuilder/.local/EasyBuildInst/modules/all && module add EasyBuild && eb --help || exit 1

#OpenPBS
qstat -a || exit 1

#XRDP
service xrdp status || exit 1
