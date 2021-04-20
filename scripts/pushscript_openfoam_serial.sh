#!/bin/bash
FV="v2012-foss-2020a 8-foss-2020b"
if [ $# -lt 4 ] || [ $# -gt 4 ]; then
cat <<EOF

usage: $0 executable version jobname walltime
- version is OpenFoam version: ($FV)
example:
./pushscript_openfoam.sh simpleFoam 8-foss-2020b myjob 01:00:00

EOF
exit 1
fi

  execfile=$1                #the job
appVersion=$2                #version of OpenFOAM used
   jobName=$3                #the jobname
     wallt=$4                #walltime

jobLogFile=$jobName.log            #the job log file
jobErrFile=$jobName.err            #the job error file

JS=jobscript.$$

case $appVersion in

    v2012-foss-2020a)
        ofVer="OpenFOAM/$appVersion"
        #mpiVer="-V mpi/OpenMPI/4.0.3-GCC-9.3.0"
        fBash="\$FOAM_BASH"
        ;;
    8-foss-2020b)
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
#PBS -l nodes=1:ppn=1

#allocating walltime
#PBS -l walltime=$wallt

#=================================================================================


#source lmod etc
source /etc/bashrc_additions

#enter pbs workdir
cd \$PBS_O_WORKDIR

#load module files
module purge
module add $ofVer

source $fBash

#--------------------------------------------------------------------------------#
#ADD OWN PRE-CODE HERE IF NECESSARY


#--------------------------------------------------------------------------------#


#start application
$execfile | tee livelog.log

rm livelog.log

result=\$?
exit \$result
EOF

chmod 700 $JS

#submit jobsscript
qsub $JS | cut -d. -f1 | echo "Job $jobName submitted with ID $(cat)"
rm $JS

exit 0
