#!/bin/bash
# These values can be overwritten with env variables
LOOP="${LOOP:-false}"
LOOP_DELAY="${LOOP_DELAY:-60}"
DB_SAVE="${DB_SAVE:-false}"
DB_HOST="${DB_HOST:-http://localhost:8086}"
DB_NAME="${DB_NAME:-speedtest}"
DB_USERNAME="${DB_USERNAME:-admin}"
DB_PASSWORD="${DB_PASSWORD:-password}"
TESTSERVER_ID="${TESTSERVER_ID:-testserverid}"

run_speedtest()
{
    DATE=$(date +%s)
    HOSTNAME=$(hostname)

    # Start speed test
    echo "Running a Speed Test..."
    date +%c
    JSON=$(speedtest --accept-license --accept-gdpr -s $TESTSERVER_ID -f json)
    ISP="$(echo $JSON | jq -r '.isp')"
    SERVERID="$(echo $JSON | jq -r '.server.id')"
    SERVER="$(echo $JSON | jq -r '.server.name')"
    SERVERLOCATION="$(echo $JSON | jq -r '.server.location')"
    DOWNLOAD="$(echo $JSON | jq -r '.download.bandwidth')"
    UPLOAD="$(echo $JSON | jq -r '.upload.bandwidth')"
    PING="$(echo $JSON | jq -r '.ping.latency')"
    echo "Your ISP is $ISP."
    echo "Your test server is $SERVER (ID $SERVERID) in $SERVERLOCATION."
    echo "Your download speed is $(($DOWNLOAD  / 125000 )) Mbps ($DOWNLOAD Bytes/s)."
    echo "Your upload speed is $(($UPLOAD  / 125000 )) Mbps ($UPLOAD Bytes/s)."
    echo "Your ping is $PING ms."

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

if $LOOP;
then
    while :
    do
        run_speedtest
        echo "Running next test in ${LOOP_DELAY}s..."
        echo ""
        sleep $LOOP_DELAY
    done
else
    run_speedtest   
fi
