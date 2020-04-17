# Internet Speed Test

## Configuration

| Environment variable | Default value           | Description                       |
| -------------------- | ----------------------- | --------------------------------- |
| `DB_SAVE`            | `false`                 | Save values to Influx DB          |
| `DB_HOST`            | `http://localhost:8086` | Influx DB Hostname                |
| `DB_NAME`            | `speedtest`             | Influx DB Database name           |
| `DB_USERNAME`        | `admin`                 | Influx DB Username                |
| `DB_PASSWORD`        | `password`              | Influx DB Password                |
| `LOOP`               | `false`                 | Run Speedtest in a loop           |
| `LOOP_DELAY`         | `60`                    | Delay in seconds between the runs |
