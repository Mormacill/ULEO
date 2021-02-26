#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
cat <<EOF
wrong count of arguments
- usage: $0 USERNAME
EOF
exit 1
fi

  USERN=$1                                  #Name of user to add

sudo adduser --force-badname $USERN         #add user to system
sudo smbpasswd -a $USERN                    #add user to samba
sudo mkdir /scratch/$USERN                  #create user scratch directory
sudo chown $USERN:$USERN /scratch/$USERN    #change owner of user scratch directory
sudo chmod 700 /scratch/$USERN              #change rights of user scratch directory
sudo usermod -aG smbusers $USERN            #add user to group smbusers to grant user authentication for samba
