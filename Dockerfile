FROM centos:centos7

MAINTAINER Schalk Snyman <schalksnyman@conor.com>

LABEL Description="This Dockerfile starts up a Riemann, InfluxDB and Grafana" Vendor="Conor Info Tech" Version="0.1"

# --------------------------
#   Environment variables
# --------------------------
ENV RIEMANN_VERSION     0.2.11
ENV INFLUXDB_VERSION    0.13.0
ENV GRAFANA_VERSION     3.0.2

# --------------------------
#   Install prerequisites
# --------------------------
# - Install epel repository required for nodejs, npm, nginx...
# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install)
# - Install yum-utils so we have yum-config-manager tool available
RUN     yum -y install epel-release && \
        yum -y update && \        
        yum -y groupinstall "Development Tools" && \
        yum -y install fontconfig nodejs npm && \
        yum -y install nginx wget && \
        yum -y install java-1.8.0-openjdk && \
        yum -y install hostname inotify-tools yum-utils which && \
        yum -y install python-setuptools && \
        easy_install supervisor && \
        yum clean all

# -------------------------------------
#   Increase OS TCP/UDP buffer limits
# -------------------------------------
# 8MB = (8*1024*1024) is starting recommendation to handle higher UDP load
RUN     echo 'net.core.rmem_max=12582912' >> /etc/sysctl.conf

RUN     echo 'net.ipv4.tcp_rmem= 10240 87380 12582912' >> /etc/sysctl.conf && \
        echo 'net.ipv4.tcp_wmem= 10240 87380 12582912' >> /etc/sysctl.conf

# Turn on window scaling
RUN     echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf

# -------------------------
#   Configure supervisord
# -------------------------

ADD     ./conf/supervisord.conf /etc/supervisord.conf

# -------------------
#   Data Volumes
# -------------------
# All persistent data in this dir
# Mount with docker argument e.g. -v /home/conor/docker_data:/mnt/docker_rig/
# 
VOLUME  /mnt/docker_rig/riemann
VOLUME  /mnt/docker_rig/influxdb
VOLUME  /mnt/docker_rig/grafana
VOLUME  /mnt/docker_rig/supervisord
VOLUME  /mnt/docker_rig/docker

# forward request and error logs to docker log collector
RUN     ln -sf /dev/stdout /mnt/docker_rig/docker/info.log
RUN     ln -sf /dev/stderr /mnt/docker_rig/docker/error.log

# -------------------------
#   Create users & groups
# -------------------------
RUN     groupadd -r -g 1200 riemann && useradd -r -g riemann -u 1200 riemann
RUN     groupadd -r -g 1300 influxdb && useradd -r -g influxdb -u 1300 influxdb
RUN     groupadd -r -g 1400 grafana && useradd -r -g grafana -u 1400 grafana

## Assign Owners
RUN     chown riemann:riemann /mnt/docker_rig/riemann
RUN     chown influxdb:influxdb /mnt/docker_rig/influxdb
RUN     chown grafana:grafana /mnt/docker_rig/grafana

# ---------------------
#   Fetch Riemann
# ---------------------
RUN     wget -c --output-document=/tmp/riemann-0.2.11.tar.bz2 https://aphyr.com/riemann/riemann-0.2.11.tar.bz2 && \
        wget -c --output-document=/tmp/riemann-check.md5 https://aphyr.com/riemann/riemann-0.2.11.tar.bz2.md5

# ---------------------
#   Install InfluxDB
# ---------------------
ADD     ./repo/influxdb.repo /etc/yum.repos.d/influxdb.repo
RUN     yum -y install influxdb

## Configure InfluxDB
ADD     ./influxdb/influxdb.conf /etc/influxdb/influxdb.conf
RUN     chown influxdb:influxdb /etc/influxdb/influxdb.conf

RUN     mkdir /mnt/docker_rig/influxdb/shared/data -p
RUN     mkdir /mnt/docker_rig/influxdb/shared/meta -p
RUN     mkdir /mnt/docker_rig/influxdb/shared/wal -p
RUN     chown influxdb:influxdb /mnt/docker_rig/influxdb -R

# ---------------------
#   Install Grafana
# ---------------------
RUN     yum -y install https://grafanarel.s3.amazonaws.com/builds/grafana-3.0.2-1463383025.x86_64.rpm
ADD     ./grafana/grafana.ini /etc/grafana/grafana.ini
RUN     chown grafana:grafana /etc/grafana/grafana.ini

# -------------------
#   Open up ports
# -------------------
# Riemann
EXPOSE  5555
EXPOSE  5556

# Influxdb ports
EXPOSE  8083
EXPOSE  8086
EXPOSE  8088

# Grafana
EXPOSE  3000 

# Supervisord
EXPOSE  9111

# Ready start_rig script
ADD     ./scripts/start_rig.sh  /etc/init.d/start_rig.sh
WORKDIR /etc/init.d
RUN     chmod 755 start_rig.sh

# Run start_rig script
CMD     bash -C 'start_rig.sh';'bash'
