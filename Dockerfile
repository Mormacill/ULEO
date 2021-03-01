FROM ubuntu:18.04

ENV LUAINSTPATH=/usr/sbin
ENV LUAVERSION=5.1.4.9
#check available Versions at https://sourceforge.net/projects/lmod/files/Lmod

ENV LMODINSTPATH=$LUAINSTPATH
ENV LMODVERSION=8.4
#check available Versions at https://sourceforge.net/projects/lmod/files/Lmod

ENV EASYBUILDVERSION=4.3.3
#check available Versions at https://github.com/easybuilders/easybuild/releases

ENV OPENPBSVERSION=20.0.1
#check available Versions at https://github.com/openpbs/openpbs/releases

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils wget nano sudo build-essential zip rsync

#change first IDs
RUN sed -i 's/FIRST_UID=1000/FIRST_UID=2000/g' /etc/adduser.conf
RUN sed -i 's/FIRST_GID=1000/FIRST_GID=2000/g' /etc/adduser.conf

#***<lua>******************************************************************************
WORKDIR /root
RUN wget https://downloads.sourceforge.net/project/lmod/lua-$LUAVERSION.tar.bz2
RUN tar -xvf lua-$LUAVERSION.tar.bz2
RUN cd lua-$LUAVERSION && ./configure --with-static=yes --prefix=$LUAINSTPATH/lua && make && make install
ENV PATH=$LUAINSTPATH/lua/bin:$PATH

#***<lmod>******************************************************************************
RUN wget https://sourceforge.net/projects/lmod/files/Lmod-$LMODVERSION.tar.bz2 
RUN tar -xvf Lmod-$LMODVERSION.tar.bz2
RUN apt-get install -y tcl-dev
RUN cd Lmod-$LMODVERSION && ./configure --prefix=$LMODINSTPATH && make install
ENV PATH=$LMODINSTPATH/lmod/$LMODVERSION/libexec:$PATH
RUN mkdir /opt/apps
ENV MODULEPATH=/opt/apps/modules/all

RUN echo 'source /etc/bashrc_additions' >> /root/.bashrc
RUN touch /etc/bashrc_additions
RUN echo 'source '$LMODINSTPATH'/lmod/'$LMODVERSION'/init/bash' >> /etc/bashrc_additions
RUN echo 'export MODULEPATH=/opt/apps/modules/all' >> /etc/bashrc_additions
RUN echo 'source /etc/bashrc_additions' >> /etc/skel/.bashrc


#***<easybuild>******************************************************************************
RUN useradd -ms /bin/bash -u 1999 easybuilder
RUN apt-get install -y python3 python3-pip
RUN wget https://github.com/easybuilders/easybuild/archive/easybuild-v$EASYBUILDVERSION.tar.gz && tar -xvf easybuild-v$EASYBUILDVERSION.tar.gz
RUN cd easybuild-easybuild-v$EASYBUILDVERSION && pip3 install --install-option "--prefix=$HOME/EasyBuild" .
RUN cp -r /root/EasyBuild /home/easybuilder && chown -R easybuilder:easybuilder /home/easybuilder/EasyBuild
USER easybuilder
RUN cd /home/easybuilder/EasyBuild/bin && python3 bootstrap_eb.py $HOME/.local/EasyBuildInst
RUN echo 'export MODULEPATH=$MODULEPATH:/home/easybuilder/.local/EasyBuildInst/modules/all' >> $HOME/.bashrc


USER root
RUN chown easybuilder:easybuilder /opt/apps
RUN apt-get install -y libssl-dev git

#***<openpbs>******************************************************************************
RUN apt-get install -y gcc make libtool libhwloc-dev libx11-dev libxt-dev libedit-dev libical-dev ncurses-dev perl postgresql-server-dev-all postgresql-contrib python3-dev tcl-dev tk-dev swig libexpat-dev libssl-dev libxext-dev libxft-dev autoconf automake
RUN apt-get install -y expat libedit2 postgresql python3 postgresql-contrib sendmail-bin sudo tcl tk libical3 postgresql-server-dev-all
USER easybuilder
WORKDIR /home/easybuilder
RUN wget https://github.com/openpbs/openpbs/archive/v$OPENPBSVERSION.tar.gz && tar -xvf v$OPENPBSVERSION.tar.gz
RUN cd openpbs-$OPENPBSVERSION && ./autogen.sh && ./configure --prefix=/opt/pbs && make
USER root
RUN cd openpbs-$OPENPBSVERSION && make install
RUN /opt/pbs/libexec/pbs_postinstall
RUN sed -i 's/PBS_START_MOM=0/PBS_START_MOM=1/g' /etc/pbs.conf
RUN chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
RUN echo 'source /etc/profile.d/pbs.sh' >> /etc/bashrc_additions

COPY scripts/pushscript_openfoam.sh /etc/skel
RUN chmod +x /etc/skel/pushscript_openfoam.sh

#***<misc>******************************************************************************
#define aliases
RUN echo "alias 'mdlsearch=module spider \$1'" >> /etc/bashrc_additions
RUN echo "alias 'livelog=watch -n 0.1 tail -n 50 *.log'" >> /etc/bashrc_additions
RUN echo "alias 'fm=foamMonitor -l -r 1 -i 180 postProcessing/residuals/0/*.dat'" >> /etc/bashrc_additions

#ssh
RUN apt-get install -y ssh
EXPOSE 22/tcp
#x11-ssh
RUN echo 'X11DisplayOffset 10' >> /etc/ssh/sshd_config
RUN echo 'X11UseLocalhost no' >> /etc/ssh/sshd_config

#***<XRDP>******************************************************************************
RUN apt-get install -y net-tools apt-utils software-properties-common
#locales
ENV LANGUAGE=en_US.UTF-8

RUN apt-get install -y locales
RUN echo '${LANGUAGE} UTF-8' >> /etc/locale.gen
RUN locale-gen ${LANGUAGE}
ENV LANG=${LANGUAGE}
ENV LC_ALL=${LANGUAGE}

#install desktop
RUN apt-get install -y xfce4 dbus-x11 xrdp
RUN echo 'xfce4-session' > /etc/skel/.xsession
RUN echo 'xfce4-session' > /home/easybuilder/.xsession && chown easybuilder:easybuilder /home/easybuilder/.xsession

#setting terminal
RUN apt-get purge -y gnome-terminal xterm && apt-get install -y tilix
#remove unnecessary software
RUN apt-get purge -y pulseaudio pavucontrol xscreensaver
#install necessary software
RUN apt-get install -y gedit firefox gnome-calculator

#disable suspend/hibernate-Buttons
RUN echo "xfconf-query -c xfce4-session -np '/shutdown/ShowSuspend' -t 'bool' -s 'false'" >> /etc/bashrc_additions
RUN echo "xfconf-query -c xfce4-session -np '/shutdown/ShowHibernate' -t 'bool' -s 'false'" >> /etc/bashrc_additions

#disable action menu and add preconfigured desktop
WORKDIR /etc/skel
RUN mkdir .config
WORKDIR /etc/skel/.config
COPY scripts/xfce4.zip .
RUN unzip xfce4.zip
RUN rm xfce4.zip

#make thinclient-folder unvisible for user
RUN sed -i 's#FuseMountName=thinclient_drives#FuseMountName=Public/thinclient_drives#g' /etc/xrdp/sesman.ini

EXPOSE 3389

#***<samba>*****************************************************************************
#samba server
RUN apt-get install -y samba

EXPOSE 445
EXPOSE 139

#samba root path
RUN mkdir /scratch

RUN mkdir /home/easybuilder/sys-samba_scripts
WORKDIR /home/easybuilder/sys-samba_scripts/
COPY /scripts/samba/system_user-smb_useradd.sh .
COPY /scripts/samba/system_user-smb_userdel.sh .
RUN chmod +x system_user-smb_useradd.sh system_user-smb_userdel.sh

#***<///>*****************************************************************************

#healthcheck
WORKDIR /
COPY scripts/healthcheck.sh .
RUN chmod +x healthcheck.sh
HEALTHCHECK --interval=1m --timeout=20s CMD ["/healthcheck.sh"]

#entrypoint
COPY scripts/entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
