#!/bin/bash

for servidor in web01 web02
do
    if ! docker inspect "$servidor" >/dev/null 2>&1; then
        echo "ERROR: No existe $servidor."
        exit 1
    fi

    estado=$(docker inspect -f '{{.State.Running}}' "$servidor" 2>/dev/null)

    if [ "$estado" != "true" ]; then
        echo "ERROR: $servidor no está ejecutándose."
        exit 1
    fi

    if ! docker run --rm --network lab-net curlimages/curl -fs "http://$servidor" >/dev/null 2>&1; then
        echo "ERROR: $servidor no responde mediante HTTP."
        exit 1
    fi
done

echo "OK: WEB01 y WEB02 están operativos."
exit 0
