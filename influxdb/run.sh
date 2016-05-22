#!/bin/bash

set -m # enable job control. All processes run in separate process groups.

CONFIG_FILE="/etc/influxdb/influxdb.conf"

echo "=> Starting InfluxDB ..."
exec /usr/bin/influxd -config=${CONFIG_FILE}

