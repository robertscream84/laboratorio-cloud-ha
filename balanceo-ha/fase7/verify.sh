#!/bin/bash

if ! docker inspect web01 >/dev/null 2>&1; then
    echo "ERROR: WEB01 no existe."
    exit 1
fi

estado_web01=$(docker inspect -f '{{.State.Running}}' web01 2>/dev/null)

if [ "$estado_web01" = "true" ]; then
    echo "ERROR: WEB01 todavía está ejecutándose."
    echo "Debe simular la falla utilizando:"
    echo "docker stop web01"
    exit 1
fi

estado_web02=$(docker inspect -f '{{.State.Running}}' web02 2>/dev/null)

if [ "$estado_web02" != "true" ]; then
    echo "ERROR: WEB02 también está detenido."
    exit 1
fi

if ! curl -fs http://localhost:8080 >/dev/null 2>&1; then
    echo "ERROR: El servicio dejó de responder."
    exit 1
fi

for i in {1..10}
do
    respuesta=$(curl -s http://localhost:8080 | grep -o 'WEB0[12]' | head -1)

    if [ "$respuesta" != "WEB02" ]; then
        echo "ERROR: Se esperaba que WEB02 procesara todas las solicitudes."
        exit 1
    fi
done

echo "OK: WEB01 está detenido."
echo "OK: WEB02 continúa operativo."
echo "OK: HAProxy mantiene disponible el servicio."
echo "RESULTADO: La prueba de resiliencia fue superada."

exit 0
