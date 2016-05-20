# conor-monitoring-rig
Simple Docker installation of the Riemann, InfluxDB and Grafana monitoring stack

# Run from GitHub folder
$ docker build -rm -t schalksnyman/conor-monitoring-rig .

# Running grafana in Docker machine
$ docker run --name=monrig -d -p 3000:3000 -p 8086:8086 -p 9111:9111 -v /Users/me/Docker/riemann:/mnt/docker_rig/riemann -v /Users/me/Docker/influxdb:/mnt/docker_rig/influxdb -v /Users/me/Docker/grafana:/mnt/docker_rig/grafana -v /Users/me/Docker/docker:/mnt/docker_rig/docker schalksnyman/conor-monitoring-rig

# Remove image if already running using container id
$ docker run --name=monrig -d -p 3000:3000 -p 8086:8086 -p 9111:9111 -v /Users/me/Docker/riemann:/mnt/docker_rig/riemann -v /Users/me/Docker/influxdb:/mnt/docker_rig/influxdb -v /Users/me/Docker/grafana:/mnt/docker_rig/grafana -v /Users/me/Docker/docker:/mnt/docker_rig/docker schalksnyman/conor-monitoring-rig
Error response from daemon: Conflict. The name "monrig" is already in use by container d6525311bac9. You have to remove (or rename) that container to be able to reuse that name.
$ docker rm d6525311bac9
d6525311bac9

# Monitor logs for running docker image
docker logs -f monrig

