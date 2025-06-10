FROM ubuntu:24.04

RUN apt update && \
  apt install -y default-jdk && \
  apt install -y jing && \
  apt install -y curl

COPY *.rng  entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
