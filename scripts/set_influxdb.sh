#!/bin/bash

set -m # enable job control. All processes run in separate proces groups.

CONFIG_FILE="/etc/influxdb/influxdb.conf"

API_URL="http://localhost:8086"

echo "=> About to create the following database: ${PRE_CREATE_DB}"
if [ -f "/.influxdb_configured" ]; then
    echo "=> Database had been created before, skipping ..."
else
    echo "=> Starting InfluxDB ..."
    exec /usr/bin/influxd -config=${CONFIG_FILE} &
    arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

    #wait for the startup of influxdb
    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of InfluxDB service startup ..."
        sleep 3 
        curl -k ${API_URL}/ping 2> /dev/null
        RET=$?
    done
    echo ""

    echo "=> Create admin User"
    curl -s -k -X POST $(echo ${API_URL}'/query') --data-urlencode "q=CREATE USER admin WITH PASSWORD '${INFLUXDB_ADMIN_PW}' WITH ALL PRIVILEGES"
    #curl -s -k -X POST -d "{\"password\":\"${ROOT_PW}\"}" $(echo ${API_URL}'/cluster_admins/root?u=root&p=root')
    echo ""

    for x in $arr
    do
        echo "=> Creating database: ${x}"
        #curl -s -k -X POST -d "{\"name\":\"${x}\"}" $(echo ${API_URL}'/db?u=root&p=root')
        curl -s -k -X POST $(echo ${API_URL}'/query') -u admin:${INFLUXDB_ADMIN_PW} --data-urlencode "q=CREATE DATABASE ${x}"
    done
    echo ""
    
    echo "=> Creating User for database: data"
    curl -s -k -X POST $(echo ${API_URL}'/query') -u admin:${INFLUXDB_ADMIN_PW} --data-urlencode "q=CREATE USER ${INFLUXDB_DATA_USER} WITH PASSWORD '${INFLUXDB_DATA_PW}'"
    curl -s -k -X POST $(echo ${API_URL}'/query') -u admin:${INFLUXDB_ADMIN_PW} --data-urlencode "q=GRANT ALL ON data TO ${INFLUXDB_DATA_USER}"
    #curl -s -k -X POST -d "{\"name\":\"${INFLUXDB_DATA_USER}\",\"password\":\"${INFLUXDB_DATA_PW}\"}" $(echo ${API_URL}'/db/data/users?u=root&p=root')
    echo "=> Creating User for database: grafana"
    curl -s -k -X POST $(echo ${API_URL}'/query') -u admin:${INFLUXDB_ADMIN_PW} --data-urlencode "q=CREATE USER ${INFLUXDB_GRAFANA_USER} WITH PASSWORD '${INFLUXDB_GRAFANA_PW}'"
    curl -s -k -X POST $(echo ${API_URL}'/query') -u admin:${INFLUXDB_ADMIN_PW} --data-urlencode "q=GRANT ALL ON grafana TO ${INFLUXDB_GRAFANA_USER}"
	#curl -s -k -X POST -d "{\"name\":\"${INFLUXDB_GRAFANA_USER}\",\"password\":\"${INFLUXDB_GRAFANA_PW}\"}" $(echo ${API_URL}'/db/grafana/users?u=root&p=root')
    echo ""
    


    touch "/.influxdb_configured"
    exit 0
fi

exit 0
