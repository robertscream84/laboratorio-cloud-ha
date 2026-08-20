# Laboratorio: Balanceo de Carga y Alta Disponibilidad

## Bienvenida

En este laboratorio se construirá paso a paso una infraestructura distribuida capaz de mantener un servicio web disponible incluso cuando uno de sus servidores presente una falla.

La práctica utiliza **Ubuntu Linux, Docker, Nginx y HAProxy**, herramientas gratuitas y de código abierto. Todo el laboratorio se ejecutará directamente desde el navegador mediante Killercoda, por lo que no se requiere instalar software adicional ni utilizar una tarjeta de crédito.

---

## Objetivo general

Implementar una infraestructura distribuida que permita experimentar con los principios fundamentales de:

* virtualización y aislamiento;
* redes privadas;
* servidores web;
* balanceo de carga;
* health checks;
* redundancia;
* alta disponibilidad;
* tolerancia a fallos;
* recuperación automática;
* escalabilidad horizontal.

El propósito no consiste únicamente en ejecutar comandos. Cada fase permitirá observar cómo cambia el comportamiento de la infraestructura a medida que se incorporan nuevos componentes.

---

## Arquitectura que se construirá

Inicialmente se implementarán dos servidores web detrás de un balanceador:

                    USUARIO
                       |
                       v
                  +----------+
                  | HAProxy  |
                  |   :8080  |
                  +----+-----+
                       |
                  Round Robin
                   /       \
                  v         v
              +-------+ +-------+
              | WEB01 | | WEB02 |
              | Nginx | | Nginx |
              +-------+ +-------+

Posteriormente se provocará intencionalmente la caída de WEB01.

HAProxy deberá detectar la falla y redirigir las solicitudes hacia WEB02:

                    USUARIO
                       |
                       v
                    HAProxy
                       |
                 +-----+-----+
                 |           |
                 v           v
              WEB01        WEB02
               DOWN          UP
                 X            |
                              v
                        100 % tráfico

Finalmente, WEB01 será recuperado y se agregará WEB03 para experimentar con escalabilidad horizontal.

---

## Fases del laboratorio

La práctica está organizada en ocho fases progresivas:

1. **Preparación del entorno**
2. **Creación de la red privada**
3. **Implementación de WEB01**
4. **Implementación de WEB02**
5. **Balanceador de carga con HAProxy**
6. **Monitoreo del balanceo**
7. **Resiliencia y alta disponibilidad**
8. **Recuperación, escalabilidad y cierre**

Cada fase depende de la infraestructura construida anteriormente.

---

## Herramientas utilizadas

### Ubuntu Linux

Sistema operativo que proporciona el entorno base del laboratorio.

### Docker

Permitirá ejecutar los diferentes componentes de la infraestructura de forma aislada.

### Nginx

Funcionará como servidor HTTP en WEB01, WEB02 y posteriormente WEB03.

### HAProxy

Actuará como balanceador de carga y realizará comprobaciones de disponibilidad sobre los servidores web.

### Killercoda

Proporcionará el entorno remoto donde se ejecutará toda la práctica desde el navegador.

---

## Relación con una infraestructura cloud

Aunque los servidores del laboratorio se representarán mediante contenedores, los principios experimentados son aplicables a arquitecturas implementadas con máquinas virtuales y servicios cloud.

Durante la práctica pueden establecerse las siguientes relaciones conceptuales:

| Laboratorio | Entorno cloud |
| --- | --- |
| Docker Network | VPC / VNet / VCN |
| WEB01 | Instancia o VM |
| WEB02 | Instancia o VM |
| WEB03 | Nueva instancia |
| HAProxy | Load Balancer |
| Health Check | Supervisión de instancias |
| `docker stop` | Falla de una instancia |
| Agregar WEB03 | Escalabilidad horizontal |

Estas tecnologías no son equivalentes. La comparación busca identificar principios arquitectónicos comunes.

---

## Tiempo estimado

**45 a 60 minutos**

Se recomienda completar el laboratorio dentro de una misma sesión, debido a que el entorno proporcionado por Killercoda es temporal.

---

## Requisitos

Para realizar la práctica únicamente se necesita:

* computadora con conexión a Internet;
* navegador web actualizado;
* acceso al escenario de Killercoda;
* conocimientos básicos de comandos Linux.

No se requiere instalar máquinas virtuales localmente.

---

## Evidencias recomendadas

Durante el laboratorio se recomienda conservar capturas de pantalla que permitan demostrar:

* creación de la red privada;
* WEB01 y WEB02 operativos;
* funcionamiento de HAProxy;
* distribución de solicitudes;
* caída de WEB01;
* continuidad del servicio mediante WEB02;
* recuperación de WEB01;
* incorporación de WEB03;
* distribución final entre tres servidores.

---

## Antes de comenzar

El laboratorio construirá una infraestructura real dentro del entorno de práctica. Algunos comandos modificarán intencionalmente su estado.

En particular, durante la Fase 7 se apagará uno de los servidores.

Esto **no representa un error del laboratorio**.

La falla será provocada deliberadamente para observar cómo responde una arquitectura diseñada con redundancia.

Cuando esté preparado, continúe con la **Fase 1: Preparación del entorno**.
