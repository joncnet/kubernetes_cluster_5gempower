## build : docker build -t 5gempower/iperf .
## run :   docker run -it 5gempower/iperf

FROM alpine:3.7
MAINTAINER Giovanni Baggio <g.baggio@fbk.eu>

RUN apk add --no-cache --virtual .build-deps iperf

# Run the launcher script
ENTRYPOINT ["iperf"]
