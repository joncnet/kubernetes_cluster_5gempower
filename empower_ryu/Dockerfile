## build : docker build -t 5gempower/empower_ryu .
## run :   docker run -it empower_ryu

FROM alpine:3.7
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>

RUN apk add --no-cache --virtual .build-deps python3-dev && apk add --no-cache --update python3 git && pip3 install --upgrade pip setuptools && apk add build-base
#RUN pip3 install python-eventlet, python-routes, python-webob, python-paramiko, python-netaddr, python-lxml, python-oslo-config, python-msgpack
RUN pip3 install netaddr eventlet oslo_config routes tinyrpc webob websocket-client

# Fetching the latest repository of empower-ryu.
RUN git clone https://github.com/5g-empower/empower-ryu.git

# Copy launcher into the container
ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
