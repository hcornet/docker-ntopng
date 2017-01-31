FROM ubuntu
MAINTAINER hcornet <thedjinhn@gmail.com>

RUN mkdir /tmp/ntopng
WORKDIR /tmp/ntopng

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y update

RUN apt-get install -y build-essential git bison flex libglib2.0 libxml2-dev libpcap-dev libtool libtool-bin rrdtool librrd-dev autoconf automake autogen redis-server wget libsqlite3-dev libhiredis-dev libgeoip-dev libcurl4-openssl-dev libpango1.0-dev libcairo2-dev libpng12-dev libmysqlclient-dev libnetfilter-queue-dev libmysqlclient-dev zlib1g-dev

RUN git clone https://github.com/ntop/nDPI.git --depth 1
WORKDIR /tmp/ntopng/nDPI
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN make check

WORKDIR /tmp/ntopng

RUN git clone https://github.com/ntop/ntopng.git --depth 1
WORKDIR /tmp/ntopng/ntopng
RUN ./autogen.sh
RUN ./configure
RUN make geoip
RUN make
RUN make install

RUN apt-get -y install libzmq-dev

EXPOSE 3000

RUN echo "#!/bin/bash" >> /tmp/run.sh
RUN echo "/etc/init.d/redis-server start" >> /tmp/run.sh
RUN echo "ntopng" >> /tmp/run.sh

RUN chmod 755 /tmp/run.sh

ENTRYPOINT ["/tmp/run.sh"]
