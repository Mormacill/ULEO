#!/bin/bash

###define test functions
function TestLmod {
  echo "test lmod" && source /usr/sbin/lmod/$LMODVERSION/init/bash && module --help &> /dev/null
  if [ $? -ne 0 ]; then
          exit 1
  fi
}
function TestEasyBuild {
  echo "test build" && export MODULEPATH=$MODULEPATH:/home/easybuilder/.local/EasyBuildInst/modules/all && module add EasyBuild && eb --help &> /dev/null
  if [ $? -ne 0 ]; then
          exit 1
  fi
}
function TestOpenPBS {
  echo "test pbs" && source /etc/profile.d/pbs.sh && qstat -a &> /dev/null
  if [ $? -ne 0 ]; then
          exit 1
  fi
}
function TestXRDP {
  echo "test xrdp" && service xrdp status &> /dev/null
  if [ $? -ne 0 ]; then
          exit 1
  fi
}

function Testsamba {
  echo "test samba" && service smbd status &> /dev/null
  if [ $? -ne 0 ]; then
          exit 1
  fi
}

###start tests
TestLmod
TestEasyBuild
TestOpenPBS
TestXRDP
Testsamba
