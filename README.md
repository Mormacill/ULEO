# Uleo-x: Ubuntu-Lmod-Easybuild-OpenPBS--Xrdp
## A scientific simulation environment for single machines with lmod environment modules, OpenPBS job manager and xfce4-desktop with Xrdp

This Dockerfile contains a lmod environment system based on lua, also easybuild is included. On top there is an OpenPBS job manager.
This Image is based on Ubuntu 18.04.

## Build the container

To build this Dockerfile just type

`docker build -t uleo-x:18.04 .`

inside the folder containing the Dockerfile. Check if the "scripts" folder is also present.
In the Dockerfile it is possible to change the versions of lua, lmod, easybuild and openPBS if you wish a different release to be installed.

## start the container

To run this Containerbuild just type

`docker run -itd -p {PortForSSHOnHost}:22/tcp -p 3389:3389 --name uleo-x --hostname uleo-x uleo-x:18.04`

The entrypoint script will start the openPBS-service and ssh daemon.

## usage

For building modules there is already an existing user called *easybuilder* with assigned rights.
**Notice: Before you make your first connect via ssh to *easybuilder* be sure to set a user account password!**
Do this by executing a bash inside the container by

`docker exec -it uleo-x bash`

Now you´re inside the container as root user. 
Assign a password by 

`passwd easybuilder`

Leave the shell and you can connect with your prefered ssh client to connect to easybuilder with your assigned password.
Due to x11 forwarding is enabled at the ssh daemon you can connect with x11 fowarding to the user to edit some files with e.g. medit.

It is also possible to access user accounts via remote desktop. For Windows use Remote Desktop, Linux users can join via Remmina client.

Network organizational chart:

![netplan](https://github.com/Mormacill/_webinclude/blob/main/NetzwerkplanSimulationsserver.png)
