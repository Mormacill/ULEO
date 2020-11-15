FROM ubuntu:20.04

ENV LUAINSTPATH=/usr/sbin
ENV LUAVERSION=5.1.4.9
#check available Versions at https://sourceforge.net/projects/lmod/files/Lmod

ENV LMODINSTPATH=$LUAINSTPATH
ENV LMODVERSION=8.4
#check available Versions at https://sourceforge.net/projects/lmod/files/Lmod

ENV EASYBUILDVERSION=4.3.1
#check available Versions at https://github.com/easybuilders/easybuild/releases

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils wget nano sudo build-essential zip rsync

#lua
WORKDIR /root
RUN wget https://downloads.sourceforge.net/project/lmod/lua-$LUAVERSION.tar.bz2
RUN tar -xvf lua-$LUAVERSION.tar.bz2
RUN cd lua-$LUAVERSION && ./configure --with-static=yes --prefix=$LUAINSTPATH/lua && make && make install
ENV PATH=$LUAINSTPATH/lua/bin:$PATH

#lmod
RUN wget https://sourceforge.net/projects/lmod/files/Lmod-$LMODVERSION.tar.bz2 
RUN tar -xvf Lmod-$LMODVERSION.tar.bz2
RUN apt-get install -y tcl-dev
RUN cd Lmod-$LMODVERSION && ./configure --prefix=$LMODINSTPATH && make install
ENV PATH=$LMODINSTPATH/lmod/$LMODVERSION/libexec:$PATH
RUN mkdir /opt/apps
ENV MODULEPATH=/opt/apps/modules/all

RUN echo 'source '$LMODINSTPATH'/lmod/'$LMODVERSION'/init/bash' >> /root/.bashrc
RUN touch /etc/bashrc_additions
RUN echo 'source '$LMODINSTPATH'/lmod/'$LMODVERSION'/init/bash' >> /etc/bashrc_additions
RUN echo 'export MODULEPATH=/opt/apps/modules/all' >> /etc/bashrc_additions
RUN echo 'source /etc/bashrc_additions' >> /etc/skel/.bashrc


#easybuild
RUN useradd -ms /bin/bash easybuilder
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


#entrypoint
ENTRYPOINT /bin/bash
