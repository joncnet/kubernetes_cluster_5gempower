FROM node:carbon

MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>

ARG USER=joncnet
ARG REPO=nextepc
ARG TAG=v0.4.2

RUN cd /usr/src; \
    git clone --branch $TAG https://github.com/$USER/$REPO

WORKDIR /usr/src/nextepc/webui
RUN npm install && \
    npm run build

RUN apt update
RUN apt install -y netcat

ADD launcher.sh /
ENTRYPOINT ["/launcher.sh"]

EXPOSE 3000
