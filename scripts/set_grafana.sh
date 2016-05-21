#!/bin/bash

set -e # exit the script if any statement returns a non-true return value

if [ -f /.grafana_configured ]; then
    echo "=> grafana has been configured!"
    exit 0
fi

echo "=> Configuring grafana"
sed -i -e "s#<--INFLUXDB_URL-->#${INFLUXDB_URL}#g" \
       -e "s/<--DATA_USER-->/${INFLUXDB_DATA_USER}/g" \
       -e "s/<--DATA_PW-->/${INFLUXDB_DATA_PW}/g" \
       -e "s/<--GRAFANA_USER-->/${INFLUXDB_GRAFANA_USER}/g" \
       -e "s/<--GRAFANA_PW-->/${INFLUXDB_GRAFANA_PW}/g" /usr/share/grafana/config.js

touch /.grafana_configured

echo "=> Grafana has been configured as follows:"
echo "   InfluxDB DB DATA NAME:  data"
echo "   InfluxDB URL: ${INFLUXDB_URL}"
echo "   InfluxDB USERNAME: ${INFLUXDB_DATA_USER}"
echo "   InfluxDB PASSWORD: ${INFLUXDB_DATA_PW}"
echo "   InfluxDB DB GRAFANA NAME:  grafana"
echo "   InfluxDB USERNAME: ${INFLUXDB_GRAFANA_USER}"
echo "   InfluxDB PASSWORD: ${INFLUXDB_GRAFANA_PW}"
echo "   ** Please check your environment variables if you find something is misconfigured. **"
echo "=> Done!"

exit 0
