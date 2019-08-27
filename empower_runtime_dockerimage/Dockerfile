## build : docker build -t 5gempower/empower_runtime .
## run :   docker run --net=host --rm --privileged -it empower_runtime

FROM ubuntu:18.04
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>
ENV ddd=33
RUN apt update
RUN apt install -y python3-dev python3 python3-pip git
RUN pip3 install tornado sqlalchemy construct==2.5.2 influxdb

# Fetching the latest repository from empower-runtime.
RUN git clone https://github.com/5g-empower/empower-runtime.git && cd empower-runtime && mkdir deploy
# git reset --hard 5bbf7d76fa4b9825250d998bd62ffc321f0ae583

# Copy downloader script into the container
ADD db_downloader.sh /
ADD launcher.sh /

# Run the launcher script
ENTRYPOINT ["/launcher.sh"]

