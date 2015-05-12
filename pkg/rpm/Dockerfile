FROM centos:centos7
MAINTAINER Zenoss <dev@zenoss.com>
RUN yum install -y make ruby-devel gcc rpm-build && gem install fpm
WORKDIR /serviced-resource-agents
ENTRYPOINT make rpm