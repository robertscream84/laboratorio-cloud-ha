#!/bin/bash

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker no se encuentra instalado."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker está instalado, pero el servicio no está operativo."
    exit 1
fi

echo "OK: Ubuntu y Docker se encuentran operativos."
exit 0
