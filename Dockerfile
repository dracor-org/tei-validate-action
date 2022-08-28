FROM ubuntu:22.04

RUN apt update && \
  apt install -y default-jdk && \
  apt install -y jing

COPY tei_all_*.rng  entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
