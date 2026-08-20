# Fase 2 - Creación de la red privada

## Objetivo de aprendizaje

En esta fase se construirá la red virtual que permitirá la comunicación entre los servidores del laboratorio.

Los servidores WEB01, WEB02 y HAProxy compartirán una red privada denominada `lab-net`.

## 1. Consultar las redes existentes

Ejecute:

`docker network ls`

Docker mostrará las redes disponibles inicialmente.

## 2. Crear la red del laboratorio

Ejecute:

`docker network create lab-net`

Esta red funcionará como segmento privado de comunicación entre los componentes de la infraestructura.

## 3. Verificar la creación

Ejecute nuevamente:

`docker network ls`

Debe aparecer una red denominada:

`lab-net`

## 4. Examinar la red

Ejecute:

`docker network inspect lab-net`

Observe especialmente los parámetros:

`Subnet`

`Gateway`

`Containers`

En este momento la sección Containers estará vacía porque todavía no se han creado los servidores.

## ¿Qué se debe observar?

La red `lab-net` proporciona un espacio de comunicación aislado para los componentes del laboratorio.

En una infraestructura cloud real, conceptos similares aparecen en servicios como Azure Virtual Network, Amazon VPC, Google Cloud VPC u OCI VCN.

La red será utilizada posteriormente por:

HAProxy → WEB01 → WEB02

## Resultado esperado

Debe existir una red Docker denominada `lab-net`.

En la siguiente fase se desplegará el primer servidor web.
