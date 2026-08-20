# Fase 1 - Preparación del entorno

## Objetivo de aprendizaje

En esta fase se comprobará que el entorno Linux y Docker están disponibles para construir la infraestructura del laboratorio.

La arquitectura que se implementará progresivamente será:

                    CLIENTE
                       |
                       v
                    HAProxy
                       |
                 +-----+-----+
                 |           |
                 v           v
               WEB01       WEB02
               Nginx       Nginx

## 1. Comprobar el sistema operativo

Ejecute:

`cat /etc/os-release`

El entorno debe identificar un sistema Ubuntu Linux.

## 2. Comprobar Docker

Ejecute:

`docker --version`

Docker permitirá crear los servidores aislados utilizados durante el laboratorio.

## 3. Comprobar el servicio

Ejecute:

`docker ps`

Inicialmente no deberían existir contenedores ejecutándose.

## ¿Qué se debe observar?

Aunque durante el laboratorio se utilizarán contenedores en lugar de tres máquinas virtuales independientes, cada servicio estará aislado y conectado mediante una red virtual.

Esto permitirá experimentar con los principios de:

* aislamiento de servicios;
* direccionamiento interno;
* balanceo de carga;
* redundancia;
* detección de fallos;
* continuidad del servicio.

## Resultado esperado

Al finalizar esta fase, Ubuntu y Docker deben encontrarse operativos.

En la siguiente fase se construirá la red privada que comunicará los servidores.
