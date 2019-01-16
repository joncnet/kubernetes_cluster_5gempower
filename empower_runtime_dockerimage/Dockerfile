## build : docker build -t 5gempower/empower_runtime .
## run :   docker run --net=host --rm --privileged -it empower_runtime

FROM alpine:3.7
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>

RUN apk add --no-cache --virtual .build-deps python3-dev && apk add --no-cache --update python3 git && pip3 install --upgrade pip setuptools
RUN pip3 install tornado sqlalchemy construct==2.5.2

# Fetching the latest repository from empower-runtime.
RUN git clone https://github.com/5g-empower/empower-runtime.git && cd empower-runtime && git reset --hard 5bbf7d76fa4b9825250d998bd62ffc321f0ae583 && mkdir deploy

# Copy downloader script into the container
ADD db_downloader.sh /
ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]
