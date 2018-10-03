## build : docker build -t empower_runtime .
## run :   docker run --net=host --rm --privileged -it empower_runtime

FROM alpine:3.7
MAINTAINER Tejas Subramanya <t.subramanya@fbk.eu>

RUN apk add --no-cache --virtual .build-deps python3-dev && apk add --no-cache --update python3 git && pip3 install --upgrade pip setuptools
RUN pip3 install tornado sqlalchemy construct==2.5.2

# Fetching the latest repository from empower-runtime.
RUN git clone https://github.com/5g-empower/empower-runtime.git && cd empower-runtime && mkdir deploy

# Run directly the controller
ENTRYPOINT ./empower-runtime/empower-runtime.py
