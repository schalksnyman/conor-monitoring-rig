#!/bin/bash

set -e # exit the script if any statement returns a non-true return value
set -u # exit script if using an uninitialised variable

# ---------------------
#   Riemann
# ---------------------
# Extract Riemann
cd /tmp
tar xvfj riemann-0.2.11.tar.bz2
md5sum -c riemann-check.md5
mv riemann-0.2.11 /mnt/docker_rig/riemann/
chown -R riemann:riemann /mnt/docker_rig/riemann/riemann-0.2.11
ls -l /mnt/docker_rig/riemann/riemann-0.2.11
# Start Riemann
#/mnt/docker_rig/riemann/riemann-0.2.11/bin/riemann /mnt/docker_rig/riemann/riemann-0.2.11/etc/riemann.config

# ---------------------
#   Supervisord
# ---------------------
# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

# Create log directory for supervisord
mkdir -p /mnt/docker_rig/supervisord/logs

# Create directories for supervisor's UNIX socket and logs (which might be missing
# as container might start with /data mounted from another data-container).
mkdir -p /data/conf /data/run /data/logs
chmod 711 /data/conf /data/run /data/logs

# Run as daemon
supervisord $SUPERVISOR_PARAMS


# ---------------------
#   InfluxDB
# ---------------------
## Start InfluxDB service now
#supervisorctl -s http://localhost:9111 -u supervisord -p sv@docker start influxdb

## Create InfluxDB Database and Users
###create admin user
curl -POST http://localhost:8086/query --data-urlencode "q=CREATE USER admin WITH PASSWORD 'cvm@2016' WITH ALL PRIVILEGES" -v

###create riemann user and db
curl -POST http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=CREATE DATABASE riemann" -v
curl -POST http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=CREATE USER riemann WITH PASSWORD 'riemann@cvm'" -v
curl -POST http://localhost:8086/query -u admin:cvm@2016 --data-urlencode "q=GRANT ALL ON riemann TO riemann" -v

# ---------------------
#   Grafana
# ---------------------
## Start Grafana service now
#supervisorctl -s http://localhost:9111 -u supervisord -p sv@docker start grafana

