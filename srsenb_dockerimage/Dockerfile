## build : docker build -t 5gempower/srsenb .
## run :   docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it 5gempower/srsenb

FROM ubuntu:18.04
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>
ENV DEBIAN_FRONTEND noninteractive

# Dependencies for the UHD driver for the USRP hardware
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get -yq install autoconf build-essential libusb-1.0-0-dev cmake wget pkg-config libboost-all-dev python-dev python-cheetah git subversion curl iproute2 net-tools iputils-ping tcpdump python3-pip

RUN pip3 install requests

# Dependencies for UHD image downloader script
RUN apt-get -yq install python-mako python-requests 

# Fetching the uhd 3.010.001 driver for our USRP SDR card 
RUN wget http://files.ettus.com/binaries/uhd/uhd_003.010.001.001-release/uhd-3.10.1.1.tar.gz && tar xvzf uhd-3.10.1.1.tar.gz && cd UHD_3.10.1.1_release && mkdir build && cd build && cmake ../ && make && make install && ldconfig && python /usr/local/lib/uhd/utils/uhd_images_downloader.py

# Dependencies for SRSeNB
RUN apt-get -yq --no-install-recommends --assume-yes install libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev


ENV sfsdfs=sfsd

# Fetch and building empower-proto 
RUN git clone https://github.com/5g-empower/empower-enb-proto && cd empower-enb-proto && make && make install

# Fetch and building empower-agent
RUN git clone https://github.com/5g-empower/empower-enb-agent && cd empower-enb-agent && make && make install

# Fetching the latest repository from 5G-EMPOWER AGENT branch and Building the srslte eNB for USRP
RUN git clone -b agent https://github.com/5g-empower/empower-srsLTE.git
ADD CMakeLists.txt /empower-srsLTE/srsenb/CMakeLists.txt
RUN cd empower-srsLTE && mkdir build && cd build && cmake ../ && make && make install

# Add configuration files from SRS
ADD enb.conf /empower-srsLTE/build/srsenb/src/
ADD drb.conf /empower-srsLTE/build/srsenb/src/
ADD rr.conf /empower-srsLTE/build/srsenb/src/
ADD sib.conf /empower-srsLTE/build/srsenb/src/
ADD sib.conf.mbsfn /empower-srsLTE/build/srsenb/src/

# Add Kubernetes launch scripts
ADD dns_replace.sh /
ADD tunnel_setup.py /

# Set env variables
ENV tunnelling=no
ENV empower_controller=no
ENV enb_id=0x19B
ENV cell_id=0x03
ENV phy_cell_id=3
ENV tac=0x0001
ENV mcc=222
ENV mnc=93
ENV n_prb=25
ENV dl_earfcn=3400

ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
