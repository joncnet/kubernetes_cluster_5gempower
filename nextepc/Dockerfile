FROM ubuntu:18.04

MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        libtool \
        gcc \
        flex \
        bison \
        git \
        libsctp-dev \
        libgnutls28-dev \
        libgcrypt-dev \
        libssl-dev \
        libidn11-dev \
        libmongoc-dev \
        libbson-dev \
        libyaml-dev \
        build-essential \
        iproute2 \
        ca-certificates \
        netbase \
        pkg-config && \
    apt-get clean

WORKDIR /root

ARG USER=joncnet
ARG REPO=nextepc
ARG TAG=v0.3.11
ARG OGSLIBREPO=ogslib
ARG OGSLIBTAG=v1.0.0

RUN git clone https://github.com/$USER/$REPO
RUN	cd nextepc && \
	git clone --branch $OGSLIBTAG https://github.com/$USER/$OGSLIBREPO lib/ogslib && \
	git fetch && git checkout -f tags/$TAG && \
	autoreconf -f -i && \
	./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--localstatedir=/var && \
	make -j `nproc` install

RUN apt update
RUN apt install -y mongo-tools netcat iptables ssh
RUN apt install -y iputils-ping net-tools tcpdump iperf

RUN mkdir /run/sshd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "root:empower"|chpasswd

ADD ue_ip.sh /root/

ADD accounts.json /
ADD subscribers.json /

ADD setup.sh /
ADD nextepc.conf /etc/nextepc/

ADD launcher.sh /

ENV k8s_dns=no

ENTRYPOINT ["/launcher.sh"]
