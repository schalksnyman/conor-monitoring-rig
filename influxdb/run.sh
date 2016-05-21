#!/bin/bash

set -m # enable job control. All processes run in separate proces groups.

CONFIG_FILE="/etc/influxdb/influxdb.conf"

echo "=> Starting InfluxDB ..."
exec /usr/bin/influxdb -config=${CONFIG_FILE}

