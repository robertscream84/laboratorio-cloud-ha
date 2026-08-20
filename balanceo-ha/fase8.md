# Fase 8 - Recuperación, escalabilidad y cierre del laboratorio

## Objetivo de aprendizaje

En esta fase se recuperará WEB01 después de la falla provocada anteriormente y se observará cómo HAProxy vuelve a incorporarlo automáticamente al conjunto de servidores disponibles.

Posteriormente se agregará un tercer servidor, WEB03, para demostrar el concepto de **escalabilidad horizontal**.

Al finalizar, el estudiante podrá diferenciar claramente:

* balanceo de carga;
* redundancia;
* resiliencia;
* recuperación;
* escalabilidad horizontal;
* punto único de falla.

---

## 1. Comprobar el estado después de la falla

Ejecute:

`docker ps -a`

El estado esperado después de la Fase 7 es:

`haproxy` → Up

`web01` → Exited

`web02` → Up

La arquitectura actual es:

```
                HAProxy
                   |
             +-----+-----+
             |           |
             v           v
          WEB01        WEB02
           DOWN           UP
             X             |
                           v
                     100 % tráfico
```

---

## 2. Comprobar que el servicio continúa operativo

Antes de recuperar WEB01, ejecute:

`for i in {1..10}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done`

Todas las solicitudes deben ser atendidas por:

`WEB02`

Esto confirma nuevamente que el servicio permaneció disponible durante la falla.

---

# Recuperación de WEB01

## 3. Iniciar nuevamente WEB01

Ejecute:

`docker start web01`

Docker debe responder:

`web01`

Espere aproximadamente entre 3 y 5 segundos para que HAProxy realice sus comprobaciones de estado.

---

## 4. Comprobar el estado

Ejecute:

`docker ps`

Ahora deben aparecer nuevamente:

`haproxy`

`web01`

`web02`

con estado:

`Up`

---

## 5. Comprobar la recuperación automática

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done`

Debe volver a observarse una alternancia similar a:

WEB01

WEB02

WEB01

WEB02

WEB01

WEB02

Esto demuestra que HAProxy detectó automáticamente que WEB01 volvió a estar disponible.

No fue necesario modificar manualmente la configuración del balanceador.

---

## 6. Medir nuevamente la distribución

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done | sort | uniq -c`

El resultado esperado será aproximadamente:

`10 WEB01`

`10 WEB02`

La infraestructura regresó a su estado normal:

```
                HAProxy
                   |
              Round Robin
               /       \
              v         v
           WEB01      WEB02
             UP         UP
            50 %       50 %
```

---

# Escalabilidad horizontal

## 7. Crear un tercer servidor WEB03

Ahora se incrementará la capacidad de la infraestructura agregando un nuevo servidor.

Ejecute:

`mkdir -p /tmp/web03`

Cree su página:

`echo '<html><body style="font-family:Arial;text-align:center;margin-top:80px"><h1>WEB03</h1><h2>Servidor Nginx operativo</h2><p>Escalabilidad horizontal</p></body></html>' > /tmp/web03/index.html`

Cree el contenedor:

`docker run -d --name web03 --network lab-net -v /tmp/web03:/usr/share/nginx/html:ro nginx:alpine`

Compruebe:

`docker ps`

Ahora deben existir:

`web01`

`web02`

`web03`

`haproxy`

---

## 8. Probar WEB03

Ejecute:

`docker run --rm --network lab-net curlimages/curl -s http://web03`

Debe aparecer:

`WEB03`

Esto confirma que el nuevo servidor está conectado correctamente a `lab-net`.

---

# Incorporar WEB03 al balanceador

## 9. Modificar la configuración de HAProxy

WEB03 existe, pero HAProxy todavía no lo conoce.

Ejecute nuevamente el siguiente bloque:

<pre>
cat > /tmp/haproxy/haproxy.cfg <<'EOF'
global
    log stdout format raw local0

defaults
    log global
    mode http
    option httplog
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend http_front
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /
    server web01 web01:80 check
    server web02 web02:80 check
    server web03 web03:80 check
EOF
</pre>

Observe la nueva línea:

`server web03 web03:80 check`

WEB03 pasa a formar parte del conjunto de servidores backend.

---

## 10. Aplicar la nueva configuración

Para simplificar el laboratorio, reinicie HAProxy.

Ejecute:

`docker restart haproxy`

Espere algunos segundos.

Compruebe:

`docker ps`

Todos los contenedores deben encontrarse en estado `Up`.

---

## 11. Probar el balanceo entre tres servidores

Ejecute:

`for i in {1..12}; do curl -s localhost:8080 | grep -o 'WEB0[123]' | head -1; done`

El resultado debe ser similar a:

WEB01

WEB02

WEB03

WEB01

WEB02

WEB03

WEB01

WEB02

WEB03

WEB01

WEB02

WEB03

Ahora HAProxy distribuye las solicitudes entre tres servidores.

---

## 12. Medir la nueva distribución

Ejecute:

`for i in {1..30}; do curl -s localhost:8080 | grep -o 'WEB0[123]' | head -1; done | sort | uniq -c`

El resultado esperado será aproximadamente:

`10 WEB01`

`10 WEB02`

`10 WEB03`

La arquitectura evolucionó desde:

```
                HAProxy
                   |
             +-----+-----+
             |           |
             v           v
          WEB01        WEB02
```

hacia:

```
                   HAProxy
                      |
            +---------+---------+
            |         |         |
            v         v         v
         WEB01      WEB02      WEB03
```

---

## ¿Qué representa este cambio?

No se incrementaron los recursos de WEB01.

Tampoco se incrementaron los recursos de WEB02.

Se agregó un servidor adicional.

Este mecanismo recibe el nombre de:

`Escalabilidad horizontal`

En una arquitectura cloud, esta estrategia permite aumentar la capacidad de procesamiento incorporando nuevas instancias.

---

# Comparación con escalabilidad vertical

## Escalabilidad vertical

Consiste en aumentar los recursos de un servidor existente.

Ejemplo:

1 vCPU → 4 vCPU

1 GB RAM → 8 GB RAM

Conceptualmente:

WEB01 pequeño → WEB01 más potente

---

## Escalabilidad horizontal

Consiste en agregar nuevas instancias.

Ejemplo:

WEB01 + WEB02

se transforma en:

WEB01 + WEB02 + WEB03

Este es el mecanismo experimentado en el laboratorio.

---

# Prueba final de resiliencia

## 13. Volver a provocar una falla

Con los tres servidores disponibles, detenga WEB02:

`docker stop web02`

Espere aproximadamente 3 segundos.

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[123]' | head -1; done`

Debe observar únicamente:

WEB01

WEB03

WEB01

WEB03

WEB01

WEB03

HAProxy detectó nuevamente la falla y distribuyó el tráfico entre los servidores restantes.

---

## 14. Recuperar WEB02

Ejecute:

`docker start web02`

Espere algunos segundos.

Después:

`for i in {1..12}; do curl -s localhost:8080 | grep -o 'WEB0[123]' | head -1; done`

Deben volver a aparecer:

WEB01

WEB02

WEB03

---

# Visualización final

Abra:

[ABRIR SERVICIO BALANCEADO]({{TRAFFIC_HOST1_8080}})

Actualice varias veces el navegador.

Deberá observar solicitudes atendidas alternativamente por:

`WEB01`

`WEB02`

`WEB03`

Esta visualización permite relacionar directamente el comportamiento del navegador con la infraestructura que funciona detrás del balanceador.

---

# Arquitectura final del laboratorio

```
                USUARIO
                   |
                   |
                   v
              +----------+
              | HAProxy  |
              |  :8080   |
              +----+-----+
                   |
               Round Robin
                   |
          +--------+--------+
          |        |        |
          v        v        v
       +------+ +------+ +------+
       |WEB01 | |WEB02 | |WEB03 |
       |Nginx | |Nginx | |Nginx |
       +------+ +------+ +------+
```

Todos los componentes se encuentran conectados mediante:

`lab-net`

---

# ¿Qué se debe observar?

Durante el laboratorio la infraestructura evolucionó progresivamente.

Inicialmente existía:

`WEB01`

Luego:

`WEB01 + WEB02`

Posteriormente:

`HAProxy + WEB01 + WEB02`

Se provocó una falla:

`WEB01 DOWN`

El servicio continuó funcionando mediante:

`WEB02`

Después WEB01 fue recuperado y HAProxy lo reincorporó automáticamente.

Finalmente se agregó:

`WEB03`

demostrando escalabilidad horizontal.

---

# Conceptos consolidados

## Virtualización y aislamiento

Docker permitió ejecutar diferentes servicios aislados dentro de un mismo entorno Linux.

Cada contenedor funcionó como un componente independiente de la infraestructura.

---

## Red privada

`lab-net`

permitió la comunicación interna entre los servidores sin necesidad de exponer cada backend directamente al usuario.

---

## Servidor web

Nginx proporcionó el servicio HTTP en:

WEB01

WEB02

WEB03

---

## Balanceo de carga

HAProxy distribuyó las solicitudes utilizando:

`Round Robin`

---

## Health Check

HAProxy supervisó continuamente la disponibilidad de los servidores mediante:

`check`

Cuando un backend dejó de responder, fue retirado temporalmente de la rotación.

---

## Redundancia

La existencia de múltiples servidores permitió que otro componente continuara atendiendo solicitudes cuando uno falló.

---

## Resiliencia

El servicio permaneció disponible durante la falla de WEB01 o WEB02.

---

## Recuperación

Cuando el servidor detenido volvió a estar disponible, HAProxy lo incorporó nuevamente al conjunto de backends.

---

## Escalabilidad horizontal

WEB03 permitió aumentar la cantidad de servidores disponibles sin modificar los recursos internos de WEB01 o WEB02.

---

# Limitación del laboratorio

Existe todavía un punto único de falla:

`HAProxy`

La arquitectura posee redundancia en la capa de servidores web, pero no en la capa del balanceador.

Si se ejecutara:

`docker stop haproxy`

el punto de acceso:

`localhost:8080`

dejaría de responder.

En una arquitectura de producción podrían utilizarse:

* múltiples balanceadores;
* direcciones IP virtuales;
* mecanismos de failover;
* balanceadores administrados por proveedores cloud;
* diferentes zonas de disponibilidad;
* replicación geográfica.

Esta limitación constituye una oportunidad para comprender que la alta disponibilidad debe analizarse en todas las capas de una arquitectura.

---

# Comparación con una infraestructura cloud real

El laboratorio puede relacionarse conceptualmente con servicios utilizados en proveedores cloud:

| Laboratorio              | Arquitectura cloud        |
| ------------------------ | ------------------------- |
| Docker Network `lab-net` | VPC / VNet / VCN          |
| Contenedor WEB01         | Instancia o VM            |
| Contenedor WEB02         | Instancia o VM            |
| Contenedor WEB03         | Nueva instancia           |
| HAProxy                  | Load Balancer             |
| `check`                  | Health Check              |
| Round Robin              | Algoritmo de balanceo     |
| `docker stop`            | Falla de instancia        |
| `docker start`           | Recuperación de instancia |
| Agregar WEB03            | Escalabilidad horizontal  |

El objetivo no consiste en considerar estas tecnologías idénticas, sino en identificar los principios de arquitectura que comparten.

---

# Reflexión final

Responda las siguientes preguntas:

1. ¿Por qué el servicio continuó funcionando cuando WEB01 fue detenido?

2. ¿Qué función cumplió el health check de HAProxy?

3. ¿Cuál es la diferencia entre balanceo de carga y alta disponibilidad?

4. ¿Por qué HAProxy representa todavía un punto único de falla?

5. ¿Qué diferencia existe entre escalabilidad horizontal y escalabilidad vertical?

6. ¿Qué ocurrió cuando WEB03 fue incorporado al backend?

7. ¿Qué componentes adicionales serían necesarios para eliminar el punto único de falla del balanceador?

---

# Evidencias del laboratorio

Se recomienda conservar capturas de:

1. `docker ps` con WEB01 y WEB02 operativos.
2. Distribución aproximada 50 % WEB01 y 50 % WEB02.
3. WEB01 en estado `Exited`.
4. Solicitudes atendidas 100 % por WEB02.
5. WEB01 recuperado.
6. Balanceo nuevamente entre WEB01 y WEB02.
7. WEB03 creado.
8. Balanceo entre WEB01, WEB02 y WEB03.
9. Página web abierta desde el navegador.
10. Arquitectura final completamente operativa.

---

# Limpieza del entorno

El entorno de Killercoda es temporal, por lo que será eliminado automáticamente al finalizar la sesión.

No obstante, para observar cómo se elimina manualmente una infraestructura puede ejecutarse:

`docker rm -f haproxy web01 web02 web03`

Después:

`docker network rm lab-net`

Finalmente:

`docker ps -a`

y:

`docker network ls`

La infraestructura creada durante el laboratorio habrá sido eliminada.

---

# Resultado final

El estudiante ha construido y experimentado con una infraestructura compuesta por:

`Red privada`

*

`Múltiples servidores web`

*

`Balanceador de carga`

*

`Health Checks`

*

`Redundancia`

*

`Recuperación`

*

`Escalabilidad horizontal`

La práctica permite observar que una infraestructura resiliente no depende únicamente de disponer de más servidores. Requiere mecanismos capaces de detectar fallos, redistribuir tráfico y reincorporar automáticamente los componentes recuperados.
