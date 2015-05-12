FROM ubuntu:14.04
MAINTAINER Zenoss <dev@zenoss.com>
RUN apt-get update && apt-get install -y make ruby-dev gcc && gem install fpm
WORKDIR /serviced-resource-agents                                               
ENTRYPOINT make deb