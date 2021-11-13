FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends build-essential curl ca-certificates git vim netcat libyaml-0-2 libreadline-dev libxml2-dev 
RUN apt-get install -y --no-install-recommends libsqlite3-dev libpq-dev libmysqlclient-dev

RUN apt-get install firefox -y
RUN apt-get install firefox-geckodriver -y

RUN which firefox
RUN which geckodriver

RUN curl -fsSL https://crystal-lang.org/install.sh | bash
RUN apt-get update -y
RUN apt-get install crystal -y

RUN which crystal

WORKDIR /opt/app
COPY . /opt/app
RUN shards build server

ENTRYPOINT ["crystal", "spec"]