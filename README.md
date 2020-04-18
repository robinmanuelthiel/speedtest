# Internet Speed Test in a Container

Check your internet bandwidth download and upload speed from a Docker container. You can configure the tool to run periodically and save the results to an InfluxDB for visualization or long-term records.

```bash
$ docker run --rm robinmanuelthiel/speedtest:latest

Running a Speed Test...
Your download speed is 334 Mbps (29284399 Bytes/s).
Your upload speed is 42 Mbps (4012944 Bytes/s).
```

## Configuration

| Environment variable | Default value           | Description                       |
| -------------------- | ----------------------- | --------------------------------- |
| `LOOP`               | `false`                 | Run Speedtest in a loop           |
| `LOOP_DELAY`         | `60`                    | Delay in seconds between the runs |
| `DB_SAVE`            | `false`                 | Save values to InfluxDB           |
| `DB_HOST`            | `http://localhost:8086` | InfluxDB Hostname                 |
| `DB_NAME`            | `speedtest`             | InfluxDB Database name            |
| `DB_USERNAME`        | `admin`                 | InfluxDB Username                 |
| `DB_PASSWORD`        | `password`              | InfluxDB Password                 |
