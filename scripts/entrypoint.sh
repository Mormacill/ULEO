#!/bin/bash

#start ssh
service ssh start 

#openPBS
sed -i s/PBS_SERVER=.*/PBS_SERVER=$HOSTNAME/g /etc/pbs.conf
sed -i s/'$clienthost.*'/'$clienthost'\ $HOSTNAME/g /var/spool/pbs/mom_priv/config
service pbs start

#xfce4 and xrdp
rm /var/run/xrdp/xrdp.pid & sleep 2
service dbus start
service xrdp start

#start samba-daemon
service smbd start

#start bash
/bin/bash
