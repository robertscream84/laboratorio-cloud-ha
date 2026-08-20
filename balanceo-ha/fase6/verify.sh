#!/bin/bash

for servicio in haproxy web01 web02
do
    if ! docker inspect "$servicio" >/dev/null 2>&1; then
        echo "ERROR: No existe $servicio."
        exit 1
    fi

    estado=$(docker inspect -f '{{.State.Running}}' "$servicio" 2>/dev/null)

    if [ "$estado" != "true" ]; then
        echo "ERROR: $servicio no está operativo."
        exit 1
    fi
done

web01=0
web02=0

for i in {1..20}
do
    respuesta=$(curl -s http://localhost:8080 | grep -o 'WEB0[12]' | head -1)

    [ "$respuesta" = "WEB01" ] && web01=$((web01+1))
    [ "$respuesta" = "WEB02" ] && web02=$((web02+1))
done

if [ "$web01" -eq 0 ] || [ "$web02" -eq 0 ]; then
    echo "ERROR: No se detectó tráfico hacia ambos servidores."
    exit 1
fi

echo "OK: Balanceo detectado."
echo "WEB01: $web01 solicitudes"
echo "WEB02: $web02 solicitudes"

exit 0
