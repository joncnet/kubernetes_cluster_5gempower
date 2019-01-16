## build : docker build -t 5gempower/srsepc .
## run :   docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it 5gempower/srsepc
## run your own config and with a PCAP :   docker run --rm --net=host --privileged -v /dev/bus/usb:/dev/bus/usb -v /YOURCONFIGDIRECTORY:/root --entrypoint /openairinterface5g/targets/bin/lte-softmodem.Rel14 openair4g -P /root/capture.pcap  -O /root/enb.conf

FROM ubuntu:18.04
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>
ENV DEBIAN_FRONTEND noninteractive
#RUN apt-get update
#RUN apt-get -yq dist-upgrade 

# Dependencies for the UHD driver for the USRP hardware
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get -yq install autoconf build-essential libusb-1.0-0-dev cmake wget pkg-config libboost-all-dev python-dev python-cheetah git subversion curl iproute2 netcat gawk iptables

# Dependencies for UHD image downloader script
RUN apt-get -yq install python-mako python-requests dos2unix

# Fetching the uhd 3.010.001 driver for our USRP SDR card 
RUN wget http://files.ettus.com/binaries/uhd/uhd_003.010.001.001-release/uhd-3.10.1.1.tar.gz && tar xvzf uhd-3.10.1.1.tar.gz && cd UHD_3.10.1.1_release && mkdir build && cd build && cmake ../ && make && make install && ldconfig && python /usr/local/lib/uhd/utils/uhd_images_downloader.py

# Dependencies for SRSeNB
RUN apt-get -yq --no-install-recommends --assume-yes install libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev

# Fetching the latest repository from SRS and Building the srslte eNB for USRP
RUN git clone https://github.com/joncnet/srsLTE && cd srsLTE && mkdir build && cd build && cmake ../ && make && make install 

# Add configuration files from SRS
ADD epc.conf /root/.srs/epc.conf
ADD mbms.conf /root/.srs/mbms.conf
ADD user_db.csv /root/.srs/user_db.csv
ADD srsepc_if_masq.sh /root/.srs/srsepc_if_masq.sh

# Add Kubernetes launch scripts
ADD dns_replace.sh /
ADD pod_ip_rest.sh /

RUN dos2unix /root/.srs/srsepc_if_masq.sh

#Add configuration files from empower-srs epc
ADD epc.conf /srsLTE/build/srsepc/src/epc.conf
ADD user_db.csv /srsLTE/build/srsepc/src/user_db.csv
ADD mbms.conf /srsLTE/build/srsepc/src/mbms.conf
ADD srsepc_if_masq.sh /srsLTE/build/srsepc/src/srsepc_if_masq.sh

RUN dos2unix /srsLTE/build/srsepc/src/srsepc_if_masq.sh

# Set env variables
ENV sgi_mb_if_addr=10.20.30.254
ENV sgi_if_addr=10.20.30.1
ENV mme_code=0x1a
ENV mme_group=0x0001
ENV tac=0x0001

ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
