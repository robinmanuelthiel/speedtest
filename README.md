# Internet Speed Test in a Container

[![Docker](https://img.shields.io/badge/Docker%20Hub-robinmanuelthiel/speedtest-blue.svg?logo=docker)](https://hub.docker.com/r/robinmanuelthiel/speedtest/)

Check your internet bandwidth using the [Speedtest CLI](https://www.speedtest.net/apps/cli) from a Docker container. You can configure the tool to run periodically and save the results to an InfluxDB for visualization or long-term records.

```bash
docker run --rm robinmanuelthiel/speedtest:latest
```

The result will then look like this:

```bash
Running a Speed Test...
Your download speed is 334 Mbps (29284399 Bytes/s).
Your upload speed is 42 Mbps (4012944 Bytes/s).
Your ping is 6.223 ms.
Speedtest took 23 seconds."
```

## Configuration

| Environment variable  | Default value           | Description                                                                          |
|-----------------------|-------------------------|--------------------------------------------------------------------------------------|
| `LOOP`                | `false`                 | Run Speedtest in a loop                                                              |
| `LOOP_DELAY`          | `60`                    | Delay in seconds between the runs                                                    |
| `DB_SAVE`             | `false`                 | Save values to InfluxDB                                                              |
| `DB_HOST`             | `http://localhost:8086` | InfluxDB Hostname                                                                    |
| `INFLUX_TOKEN`        | `""`                    | InfluxDB v2 Authentication Token (required for v2 API)                                |
| `INFLUX_ORG`         | `speedtest`             | InfluxDB v2 Organization name (required for v2 API)                                 |
| `INFLUX_BUCKET`      | `speedtest`             | InfluxDB v2 Bucket name (required for v2 API)                                      |

**Note:** For production deployments, it's recommended to set sensitive values like `INFLUX_TOKEN` using secure environment variables rather than hardcoding them.
| `SPEEDTEST_SERVER_ID` | none                    | Specify a server from the server list using its ID                                   |
| `SPEEDTEST_HOSTNAME`  | none                    | Specify a server, from the server list, using its host's fully qualified domain name |

To get the available Server IDs, sponsors, and hostnames from speedtest run:

```bash
curl -s https://cli.speedtest.net/api/cli/config | jq -r '.servers[] | "id: \(.id), sponsor: \(.sponsor), host: \(.host)"'
```

## Grafana and InfluxDB

![Screenshot of a Grafana Dashboard with upload and download speed values](img/grafana.png)

For a full visualization and long term tracking, I recommend InfluxDB as a time-series database and Grafana as a dashboard engine. Both come in Docker containers, so the whole setup can be achieved by starting a Docker Compose file.

```yaml
version: "3"
services:
  grafana:
    image: grafana/grafana:7.5.2
    restart: always
    ports:
      - 3000:3000
    volumes:
      - grafana:/var/lib/grafana
    depends_on:
      - influxdb

  influxdb:
    image: influxdb:1.8.3
    restart: always
    volumes:
      - influxdb:/var/lib/influxdb
    ports:
      - 8083:8083
      - 8086:8086
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=password123
      - DOCKER_INFLUXDB_INIT_ORG=speedtest
      - DOCKER_INFLUXDB_INIT_BUCKET=speedtest
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-auth-token

  speedtest:
    image: robinmanuelthiel/speedtest:latest
    restart: always
    environment:
      - LOOP=true
      - LOOP_DELAY=1800
      - DB_SAVE=true
      - DB_HOST=http://influxdb:8086
      - INFLUX_TOKEN=my-super-secret-auth-token
      - INFLUX_ORG=speedtest
      - INFLUX_BUCKET=speedtest
    privileged: true # Needed for 'sleep' in the loop
    depends_on:
      - influxdb

volumes:
  grafana:
  influxdb:
```

To configure Grafana, we need to **add InfluxDB as a data source first** and then create a dashboard with the upload and download values. You can find a demo dashboard configuration in the [/demo](/demo) folder.

> **Hint:** The speedtest outputs values as bytes per second. Make sure to divide all values by 125000 in your dashboard to get the Mbps values.
