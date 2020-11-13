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
RUN export PATH=$LUAINSTPATH/lua/bin:$PATH
RUN cd /root

#lmod
RUN wget https://sourceforge.net/projects/lmod/files/Lmod-8.4.tar.bz2 
RUN tar -xvf Lmod-8.4.tar.bz2
RUN apt-get install -y tcl-dev
RUN cd Lmod-8.4 && ln -s $LUAINSTPATH/lua/bin/lua lua && ./configure --prefix=$LMODINSTPATH && make install
RUN export PATH=$LMODINSTPATH/lmod/6.1/libexec:$PATH
RUN mkdir /apps
ENV MODULEPATH=/apps

#entrypoint
RUN echo 'source $LMODINSTPATH/lmod/8.4/init/bash' > /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
