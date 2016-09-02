FROM ubuntu:14.04

ENV PARITY_DEB_URL=https://vanity-service.ethcore.io/github-data/latest-parity-deb
ENV PASSWORD=$1

RUN apt-get update
RUN apt-get install -y -qq curl expect expect-dev

# install parity #
ENV parity_deb=/tmp/parity.deb
RUN curl -Lk $PARITY_DEB_URL > $parity_deb
RUN sudo dpkg -i $parity_deb



