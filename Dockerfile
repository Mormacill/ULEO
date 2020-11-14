FROM ubuntu:20.04

ENV LUAINSTPATH=/usr/sbin
ENV LMODINSTPATH=$LUAINSTPATH

#timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils wget nano sudo build-essential zip rsync

#lua
RUN wget https://downloads.sourceforge.net/project/lmod/lua-5.1.4.9.tar.bz2
RUN tar -xvf lua-5.1.4.9.tar.bz2
RUN cd lua-5.1.4.9 && ./configure --with-static=yes --prefix=$LUAINSTPATH/lua && make && make install
ENV PATH=$LUAINSTPATH/lua/bin:$PATH
RUN cd /root

#lmod
RUN wget https://sourceforge.net/projects/lmod/files/Lmod-8.4.tar.bz2 
RUN tar -xvf Lmod-8.4.tar.bz2
RUN apt-get install -y tcl-dev
RUN cd Lmod-8.4 && ./configure --prefix=$LMODINSTPATH && make install
ENV PATH=$LMODINSTPATH/lmod/8.4/libexec:$PATH
RUN mkdir /opt/apps
ENV MODULEPATH=/opt/apps

RUN echo 'source $LMODINSTPATH/lmod/8.4/init/bash' >> /root/.bashrc


#easybuild
RUN useradd -ms /bin/bash easybuild_user
RUN apt-get install -y python3 python3-pip
RUN wget https://github.com/easybuilders/easybuild/archive/easybuild-v4.3.1.tar.gz && tar -xvf easybuild-v4.3.1.tar.gz
RUN cd easybuild-easybuild-v4.3.1 && pip3 install --install-option "--prefix=$HOME/EasyBuild" .
RUN cp -r /root/EasyBuild /home/easybuild_user && chown -R easybuild_user:easybuild_user /home/easybuild_user/EasyBuild
USER easybuild_user
RUN cd /home/easybuild_user/EasyBuild/bin && python3 bootstrap_eb.py $HOME/.local/EasyBuildInst
RUN echo 'export MODULEPATH=$MODULEPATH:/home/easybuild_user/.local/EasyBuildInst/modules/all' >> $HOME/.bashrc

USER root
RUN apt-get install -y libssl-dev


#entrypoint
ENTRYPOINT /bin/bash
