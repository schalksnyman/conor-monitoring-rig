FROM centos:centos7
MAINTAINER Schalk Snyman <schalksnyman@conor.com>

LABEL Description="This Dockerfile starts up a Riemann, InfluxDB and Grafana" Vendor="Conor Info Tech" Version="0.1"

# --------------------------
#   Environment variables
# --------------------------
ENV RIEMANN_VERSION     0.2.11
ENV INFLUXDB_VERSION    0.13.1
ENV GRAFANA_VERSION     3.0.2

# --------------------------
#   Install prerequisites
# --------------------------
RUN     yum -y install epel-release # required for nodejs, npm, nginx...
RUN     yum -y update
RUN     yum -y groupinstall "Development Tools"
RUN     yum -y install fontconfig nodejs npm
RUN     yum -y install nginx

# -----------------------------
#   Increase OS TCP/UDP buffer 
#   limits
# -----------------------------
#8MB = (8*1024*1024) is starting recommendation to handle higher UDP load
RUN     echo 'net.core.rmem_max=12582912' >> /etc/sysctl.conf

RUN     echo 'net.ipv4.tcp_rmem= 10240 87380 12582912' >> /etc/sysctl.conf
RUN     echo 'net.ipv4.tcp_wmem= 10240 87380 12582912' >> /etc/sysctl.conf

#Turn on window scaling
RUN     echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf

# -----------------------
#   Install supervisord
# -----------------------
# python-setuptools is required to have python's easy_install
RUN     yum -y install python-setuptools
RUN     easy_install supervisor
RUN     yum -y install java-1.8.0-openjdk
#ADD     ./supervisord.conf.d/* /etc/supervisor/conf.d/


# -------------------
#   Data Volumes
# -------------------
# All persistent data in this dir
# Mount with docker argument e.g. -v /home/conor/docker_data:/mnt/docker_rig/
# 
VOLUME  /mnt/docker_rig/riemann
VOLUME  /mnt/docker_rig/influxdb
VOLUME  /mnt/docker_rig/grafana

# -------------------------
#   Create users & groups
# -------------------------
RUN groupadd -r -g 1200 riemann && useradd -r -g riemann -u 1200 riemann
RUN groupadd -r -g 1300 influxdb && useradd -r -g influxdb -u 1300 influxdb
RUN groupadd -r -g 1400 grafana && useradd -r -g grafana -u 1400 grafana

# -------------------------
#   Create Directories
# ------------------------- 
#RUN     mkdir -p /mnt/docker_rig/riemann
#RUN     mkdir -p /mnt/docker_rig/influxdb
#RUN     mkdir -p /mnt/docker_rig/grafana

## Assign Owners
RUN     chown riemann:riemann /mnt/docker_rig/riemann
RUN     chown influxdb:influxdb /mnt/docker_rig/influxdb
RUN     chown grafana:grafana /mnt/docker_rig/grafana

# ---------------------
#   Install & Start Riemann
# ---------------------
RUN     wget -c https://aphyr.com/riemann/riemann-0.2.11.tar.bz2 && \
        tar xvfj riemann.tar.bz2 && \
        cd riemann-0.2.11 && \
        wget https://aphyr.com/riemann/riemann-0.2.11.tar.bz2.md5 && \
        md5sum -c riemann-0.2.11.tar.bz2.md5 && \
        bin/riemann etc/riemann.config &

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

## Start now
#RUN     systemctl start influxdb.service
#RUN     systemctl status influxdb.service

## Create Database and Users
###create admin user
#RUN     curl -G http://localhost:8086/query --data-urlencode "q=CREATE USER admin WITH PASSWORD 'cvm@2016' WITH ALL PRIVILEGES" -v

###create riemann user and db
#RUN     curl -G http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=CREATE DATABASE riemann" -v
#RUN     curl -G http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=CREATE USER riemann WITH PASSWORD 'riemann@cvm'" -v
#RUN     curl -G http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=GRANT ALL ON riemann TO riemann" -v

# ---------------------
#   Install Grafana
# ---------------------
RUN     yum -y install https://grafanarel.s3.amazonaws.com/builds/grafana-3.0.2-1463383025.x86_64.rpm
ADD     ./grafana/grafana.ini /etc/grafana/grafana.ini

## Start now
#RUN     systemctl start grafana-server
#RUN     systemctl status grafana-server

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

