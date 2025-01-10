#!/bin/sh
# These values can be overwritten with env variables
LOOP="${LOOP:-false}"
LOOP_DELAY="${LOOP_DELAY:-60}"
DB_SAVE="${DB_SAVE:-false}"
DB_HOST="${DB_HOST:-http://localhost:8086}"
DB_NAME="${DB_NAME:-speedtest}"
DB_USERNAME="${DB_USERNAME:-admin}"
DB_PASSWORD="${DB_PASSWORD:-password}"
SPEEDTEST_HOSTNAME="${SPEEDTEST_HOSTNAME}"
SPEEDTEST_SERVER_ID="${SPEEDTEST_SERVER_ID}"

run_speedtest()
{
    DATE=$(date +%s)
    HOSTNAME=$(hostname)
    START_TIME=$(date +%s)

    # Start speed test
    if [ -n "$SPEEDTEST_SERVER_ID" ]; then
        echo "Running a Speed Test with Server ID $SPEEDTEST_SERVER_ID... "
        JSON=$(speedtest --accept-license --accept-gdpr -f json -s $SPEEDTEST_SERVER_ID) || JSON=""
    elif [ -n "$SPEEDTEST_HOSTNAME" ]; then
        echo "Running a Speed Test with Hostname $SPEEDTEST_HOSTNAME... "
        JSON=$(speedtest --accept-license --accept-gdpr -f json -o $SPEEDTEST_HOSTNAME) || JSON=""
    else
        echo "Running a Speed Test with default host... "
        JSON=$(speedtest --accept-license --accept-gdpr -f json) || JSON=""
    fi

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))    

    # If JSON is empty, then the speedtest command failed.
    # In this case set the values to 0.
    if [ -z "$JSON" ]; then
        DOWNLOAD=0
        UPLOAD=0
        PING=0
    else
        # Fetch the values from the JSON output and convert them to the correct units (converts null to 0)
        DOWNLOAD="$(echo $JSON | jq -r '.download.bandwidth // 0')"
        UPLOAD="$(echo $JSON | jq -r '.upload.bandwidth // 0')"
        PING="$(echo $JSON | jq -r '.ping.latency // 0')"
    fi

    echo "Your download speed is $(($DOWNLOAD / 125000 )) Mbps ($DOWNLOAD Bytes/s)."
    echo "Your upload speed is $(($UPLOAD / 125000 )) Mbps ($UPLOAD Bytes/s)."
    echo "Your ping is $PING ms."
    echo "Speedtest took $DURATION seconds."

    # Save results in the database
    if $DB_SAVE; 
    then
        echo "Saving values to database..."
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "download,host=$HOSTNAME value=$DOWNLOAD $DATE"
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "upload,host=$HOSTNAME value=$UPLOAD $DATE"
        curl -s -S -XPOST "$DB_HOST/write?db=$DB_NAME&precision=s&u=$DB_USERNAME&p=$DB_PASSWORD" \
            --data-binary "ping,host=$HOSTNAME value=$PING $DATE"
        echo "Values saved."
    fi
}

# Check for input errors
if [ -n "$SPEEDTEST_SERVER_ID" ] && [ -n "$SPEEDTEST_HOSTNAME" ]; then
    echo >&2 "[error] Only one server option can be specified, please use one of ['SPEEDTEST_SERVER_ID' or 'SPEEDTEST_HOSTNAME']"
    exit 1
fi

if $LOOP;
then
    echo "Running speedtest in a loop until stopped..."
    while :
    do
        run_speedtest
        echo "Running next test in ${LOOP_DELAY}s..."
        sleep $LOOP_DELAY
    done
else
    run_speedtest
fi
