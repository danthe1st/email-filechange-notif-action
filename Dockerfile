FROM ubuntu:latest

RUN apt update
RUN apt install -y bash curl sendemail jq git libnet-ssleay-perl libio-socket-ssl-perl

COPY src /work
RUN chmod +x /work/*.sh

WORKDIR /work

ENTRYPOINT ["/work/entrypoint.sh"]
