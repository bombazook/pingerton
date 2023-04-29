ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION

RUN apt update -y && apt install -y curl bash libpcap-dev

RUN mkdir -p /usr/local/bundle
RUN mkdir -p /usr/src/app

ENV BUNDLE_PATH /usr/local/bundle

WORKDIR /usr/src/app
