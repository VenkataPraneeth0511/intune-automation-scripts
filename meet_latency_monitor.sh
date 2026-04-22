#!/bin/bash

THRESHOLD=150

echo "Monitoring Google Meet (1e100.net endpoints)..."
echo "----------------------------------------------"

while true
do
    IPS=$(sudo lsof -i | grep -i "1e100.net" | awk '{print $9}' | awk -F'->' '{print $2}' | awk -F':' '{print $1}' | sort -u)

    if [[ -z "$IPS" ]]; then
        echo "$(date): No Meet endpoints detected"
    else
        for IP in $IPS
        do
            LATENCY=$(ping -c 1 -W 1000 $IP 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')

            if [[ -n "$LATENCY" ]]; then
                LATENCY_INT=${LATENCY%.*}

                if [ "$LATENCY_INT" -gt "$THRESHOLD" ]; then
                    echo "$(date): ⚠️ HIGH LATENCY - $IP (${LATENCY} ms)"
                    osascript -e "display notification \"Meet latency: ${LATENCY} ms\" with title \"Google Meet Alert\""
                else
                    echo "$(date): OK - $IP (${LATENCY} ms)"
                fi
            else
                echo "$(date): No ping response from $IP"
            fi
        done
    fi

    sleep 5
done