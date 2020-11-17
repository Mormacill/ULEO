#!bin/bash

#start ssh
service ssh start 

#start jobmanager openPBS
/etc/init.d/pbs start

#start bash
/bin/bash 
