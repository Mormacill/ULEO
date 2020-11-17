#!bin/bash

#start ssh
service ssh start 

#start jobmanager openPBS
service pbs start

#start bash
/bin/bash
