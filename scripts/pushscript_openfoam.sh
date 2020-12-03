#!/bin/bash
FV="v2006-foss-2020a 8-foss-2020a"
if [ $# -lt 4 ] || [ $# -gt 4 ]; then
cat <<EOF

usage: $0 executable cores version jobname
- version is OpenFoam version: ($FV)

EOF
exit 1
fi

  execfile=$1                #the job
    nprocs=$2                #number of CPUs to run on
appVersion=$3                #version of OpenFOAM used
   jobName=$4                #the jobname

jobLogFile=$jobName.log            #the job log file
jobErrFile=$jobName.err            #the job error file

JS=jobscript.$$

case $appVersion in

    v2006-foss-2020a)
        ofVer="OpenFOAM/$appVersion"
        #mpiVer="-V mpi/OpenMPI/4.0.3-GCC-9.3.0"
        fBash="\$FOAM_BASH"
        ;;
    8-foss-2020a)
        ofVer="OpenFOAM/$appVersion"
        #mpiVer="-V mpi/OpenMPI/4.0.3-GCC-9.3.0"
        fBash="\$FOAM_BASH"
        ;;
    *)
        cat << EOF
Wrong OpenFoam version ($appVersion) given.
Allowed versions are: $FV
EOF
        exit 1
        ;;
esac

echo "Writing job script for OpenFoam $appVersion"

cat >> $JS << EOF
#! /bin/bash

#=================================================================================
#
# Job script for running OpenFoam $appVersion
#
#=================================================================================

#pbs-parameters

#output-Log
#PBS -o $jobLogFile

#error-Log
#PBS -e $jobErrFile

#jobname, visible in qstat
#PBS -N $jobName

#ressource allocating
#PBS -l nodes=1:ppn=$nprocs

#=================================================================================


#source lmod etc
source /etc/bashrc_additions

#enter pbs workdir
cd \$PBS_O_WORKDIR

#load module files
module purge
module add $ofVer

source $fBash

#start application
mpirun -np $nprocs $execfile -parallel | tee livelog.log

rm livelog.log

result=\$?
exit \$result
EOF

chmod 700 $JS

#submit jobsscript
qsub $JS | cut -d. -f1 | echo "Job $jobName submitted with ID $(cat)"
rm $JS

exit 0
