#!/bin/bash

if ! docker inspect haproxy >/dev/null 2>&1; then
    echo "ERROR: No existe el contenedor haproxy."
    exit 1
fi

estado=$(docker inspect -f '{{.State.Running}}' haproxy 2>/dev/null)

if [ "$estado" != "true" ]; then
    echo "ERROR: HAProxy existe, pero no está ejecutándose."
    exit 1
fi

if ! curl -fs http://localhost:8080 >/dev/null 2>&1; then
    echo "ERROR: El balanceador no responde en localhost:8080."
    exit 1
fi

resultado=""

for i in {1..10}
do
    respuesta=$(curl -s http://localhost:8080 | grep -o 'WEB0[12]' | head -1)
    resultado="$resultado $respuesta"
done

if ! echo "$resultado" | grep -q "WEB01"; then
    echo "ERROR: HAProxy no está enviando tráfico hacia WEB01."
    exit 1
fi

if ! echo "$resultado" | grep -q "WEB02"; then
    echo "ERROR: HAProxy no está enviando tráfico hacia WEB02."
    exit 1
fi

echo "OK: HAProxy responde y distribuye tráfico entre WEB01 y WEB02."
exit 0
