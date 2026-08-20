# Fase 6 - Monitoreo del balanceo de carga

## Objetivo de aprendizaje

En esta fase se observará el comportamiento del balanceador mediante solicitudes consecutivas y mediante el panel de estadísticas de HAProxy.

El objetivo es identificar cómo HAProxy distribuye el tráfico y supervisa permanentemente el estado de WEB01 y WEB02.

---

## 1. Comprobar la infraestructura

Ejecute:

`docker ps`

Deben encontrarse operativos:

`haproxy`

`web01`

`web02`

La arquitectura actual es:

                    CLIENTE
                       |
                       v
                    HAProxy
                       |
                  Round Robin
                  /         \
                 v           v
              WEB01        WEB02
               UP            UP

---

## 2. Generar tráfico

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done`

Se generarán veinte solicitudes HTTP.

Debe observar una distribución similar a:

WEB01

WEB02

WEB01

WEB02

WEB01

WEB02

El servidor que responde primero puede variar.

---

## 3. Contar las respuestas de cada servidor

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done | sort | uniq -c`

El resultado esperado será aproximadamente:

`10 WEB01`

`10 WEB02`

Esto demuestra que el algoritmo Round Robin distribuye las solicitudes entre los dos servidores disponibles.

---

## 4. Consultar los logs de HAProxy

Ejecute:

`docker logs haproxy --tail 20`

Los registros permiten observar las solicitudes procesadas por el balanceador.

Los logs constituyen una herramienta fundamental para monitorear y diagnosticar infraestructuras distribuidas.

---

## 5. Examinar el estado de los contenedores

Ejecute:

`docker stats --no-stream`

Observe especialmente:

CPU

MEM USAGE

NET I/O

Aunque el laboratorio utiliza una carga pequeña, cada servidor consume recursos de manera independiente.

---

## 6. Visualizar la página balanceada

Abra el servicio mediante:

[ABRIR SERVICIO BALANCEADO]({{TRAFFIC_HOST1_8080}})

Actualice varias veces la página.

Observe cuál servidor responde:

`WEB01`

o

`WEB02`

Cada actualización del navegador representa una nueva solicitud enviada al balanceador.

---

## ¿Qué se debe observar?

El usuario accede siempre al mismo punto de entrada.

`HAProxy`

Sin embargo, las solicitudes son procesadas por diferentes servidores.

El cliente no necesita conocer la dirección de WEB01 ni WEB02.

Esta separación permite modificar la infraestructura interna sin cambiar la forma en que los usuarios acceden al servicio.

---

## Balanceo frente a alta disponibilidad

Hasta este momento se ha demostrado:

`Balanceo de carga`

Los dos servidores están disponibles y reciben tráfico.

                    HAProxy
                       |
                 +-----+-----+
                 |           |
                 v           v
              WEB01        WEB02
               UP            UP
               50%           50%

Todavía falta comprobar una característica crítica:

`¿Qué ocurre cuando uno de los servidores falla?`

Esta pregunta será respondida experimentalmente en la siguiente fase.

---

## Resultado esperado

Al finalizar esta fase se debe comprobar que:

* HAProxy recibe las solicitudes.
* WEB01 y WEB02 procesan tráfico.
* Round Robin distribuye las solicitudes.
* Los servidores pueden monitorearse.
* El cliente utiliza un único punto de acceso.

En la siguiente fase se provocará intencionalmente la caída de WEB01 para comprobar si el servicio continúa disponible.
