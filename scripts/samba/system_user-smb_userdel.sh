#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
cat <<EOF
wrong count of arguments
- usage: $0 USERNAME
EOF
exit 1
fi

  USERN=$1                                  #Name of user to add

sudo deluser $USERN smbusers              #remove user from group smbusers
sudo rm -rf /scratch/$USERN               #delete user scratch directory
sudo smbpasswd -x $USERN                  #delete user from samba
sudo deluser --remove-home $USERN         #delete user from system
