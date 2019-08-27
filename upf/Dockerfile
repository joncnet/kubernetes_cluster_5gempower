FROM ubuntu:18.04
MAINTAINER g.baggio@fbk.eu

RUN apt update
RUN apt install -y build-essential cmake autoconf
RUN apt install -y nano tcpdump net-tools iputils-ping git python python-pip iptables iproute2

RUN git clone https://github.com/5g-empower/empower-lvap-agent.git
WORKDIR /empower-lvap-agent
RUN ./configure --disable-linuxmodule --enable-userlevel --enable-wifi --enable-empower --enable-lvnfs
RUN make
RUN make install
WORKDIR /

ADD modes /modes
ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
