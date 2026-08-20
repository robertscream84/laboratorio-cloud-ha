#!/bin/bash

if ! docker network inspect lab-net >/dev/null 2>&1; then
    echo "ERROR: No existe la red lab-net."
    echo "Ejecute: docker network create lab-net"
    exit 1
fi

echo "OK: La red privada lab-net existe."
exit 0
