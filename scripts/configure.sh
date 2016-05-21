#!/bin/bash

set -e # exit the script if any statement returns a non-true return value

if [ ! -f "/.grafana_configured" ]; then
    /set_grafana.sh
fi

if [ ! -f "/.influxdb_configured" ]; then
    /set_influxdb.sh
fi

exit 0
