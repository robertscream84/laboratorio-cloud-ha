#!/bin/bash

if ! docker network inspect lab-net >/dev/null 2>&1; then
    echo "ERROR: No existe la red lab-net."
    exit 1
fi

if ! docker inspect web01 >/dev/null 2>&1; then
    echo "ERROR: No existe el contenedor web01."
    exit 1
fi

estado=$(docker inspect -f '{{.State.Running}}' web01 2>/dev/null)

if [ "$estado" != "true" ]; then
    echo "ERROR: WEB01 existe, pero no está ejecutándose."
    exit 1
fi

if ! docker run --rm --network lab-net curlimages/curl -fs http://web01 >/dev/null 2>&1; then
    echo "ERROR: WEB01 no responde mediante HTTP."
    exit 1
fi

echo "OK: WEB01 está operativo y responde mediante HTTP."
exit 0
