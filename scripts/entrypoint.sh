#!bin/bash

#start ssh
service ssh start 

#openPBS
sed -i s/PBS_SERVER=.*/PBS_SERVER=$HOSTNAME/g /etc/pbs.conf
sed -i s/'$clienthost.*'/'$clienthost'\ $HOSTNAME/g /var/spool/pbs/mom_priv/config
service pbs start

#start bash
/bin/bash
