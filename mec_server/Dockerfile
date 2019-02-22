## build : docker build -t 5gempower/srsepc .
## run :   docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it 5gempower/srsepc
## run your own config and with a PCAP :   docker run --rm --net=host --privileged -v /dev/bus/usb:/dev/bus/usb -v /YOURCONFIGDIRECTORY:/root --entrypoint /openairinterface5g/targets/bin/lte-softmodem.Rel14 openair4g -P /root/capture.pcap  -O /root/enb.conf

FROM ubuntu:18.04
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get -yq install autoconf build-essential cmake wget python3 iproute2 netcat gawk iptables net-tools tcpdump iputils-ping openvswitch-switch python3-pip

RUN pip3 install tornado

RUN apt-get -yq install git screen

# Add Kubernetes launch scripts
ADD mec_agent.py /
ADD install_mec.sh /
ADD start_mec.sh /
ADD launcher.sh /

# TEMPORARY FIX
RUN cp /bin/true /sbin/modprobe

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
