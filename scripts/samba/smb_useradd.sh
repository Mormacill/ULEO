#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 1 ]; then
cat <<EOF
wrong count of arguments
- usage: $0 USERNAME
EOF
exit 1
fi

  USERN=$1                #Name of user to add

sudo adduser --force-badname $USERN
sudo smbpasswd -a $USERN
sudo mkdir /scratch/$USERN
sudo chown $USERN:$USERN /scratch/$USERN
sudo chmod 700 /scratch/$USERN
sudo usermod -aG smbusers $USERN
