FROM ubuntu:18.04
MAINTAINER g.baggio@fbk.eu

RUN apt update
RUN apt-get -y install strongswan strongswan-pki libcharon-extra-plugins
RUN apt-get -y install nano tcpdump net-tools iputils-ping

ADD ipsec.conf /etc/
ADD ipsec.secrets /etc/
ADD ca-cert.pem /etc/ipsec.d/cacerts/
ADD ca-key.pem /etc/ipsec.d/private/

ADD env_replace.sh /
ADD generate_certificate.sh /
ADD rules.sh /

ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
