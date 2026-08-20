# Fase 5 - Balanceador de carga con HAProxy

## Objetivo de aprendizaje

En esta fase se implementará un balanceador de carga utilizando HAProxy.

El balanceador recibirá las solicitudes HTTP de los usuarios y las distribuirá entre los servidores WEB01 y WEB02.

La arquitectura será:

                    CLIENTE
                       |
                       |
                       v
                  +----------+
                  | HAProxy  |
                  |  :8080   |
                  +----+-----+
                       |
                  Round Robin
                   /       \
                  /         \
                 v           v
             +--------+  +--------+
             | WEB01  |  | WEB02  |
             | Nginx  |  | Nginx  |
             +--------+  +--------+

HAProxy utilizará además mecanismos de comprobación de estado para determinar si los servidores se encuentran disponibles.

---

## 1. Comprobar la infraestructura existente

Antes de configurar el balanceador, compruebe los contenedores:

`docker ps`

Deben aparecer:

`web01`

`web02`

Ambos deben encontrarse en estado `Up`.

Compruebe también la red:

`docker network ls`

Debe existir:

`lab-net`

Si la red no existe, créela mediante:

`docker network create lab-net`

---

## 2. Crear el directorio de configuración de HAProxy

Ejecute:

`mkdir -p /tmp/haproxy`

Este directorio almacenará el archivo de configuración utilizado por el balanceador.

---

## 3. Crear la configuración de HAProxy

Ejecute el siguiente bloque completo:

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
EOF
</pre>

---

## 4. Examinar la configuración

Ejecute:

`cat /tmp/haproxy/haproxy.cfg`

Observe especialmente:

`balance roundrobin`

Este parámetro establece el algoritmo de balanceo.

Round Robin distribuye secuencialmente las solicitudes entre los servidores disponibles.

También aparecen:

`server web01 web01:80 check`

`server web02 web02:80 check`

La opción `check` indica a HAProxy que debe comprobar periódicamente si cada servidor se encuentra disponible.

---

## 5. Crear el balanceador

Ejecute:

`docker run -d --name haproxy --network lab-net -p 8080:80 -v /tmp/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:alpine`

Docker descargará la imagen de HAProxy si todavía no está disponible.

El parámetro:

`--network lab-net`

conecta HAProxy a la misma red que WEB01 y WEB02.

El parámetro:

`-p 8080:80`

publica el servicio mediante el puerto 8080 del entorno.

La comunicación queda:

Cliente -> puerto 8080 -> HAProxy puerto 80

---

## 6. Verificar los tres servidores

Ejecute:

`docker ps`

Deben aparecer tres contenedores:

`haproxy`

`web01`

`web02`

Los tres deben mostrar estado:

`Up`

La infraestructura ahora está formada por:

                    HAProxy
                       |
                  +----+----+
                  |         |
                  v         v
                WEB01     WEB02

---

## 7. Realizar la primera solicitud

Ejecute:

`curl -s localhost:8080`

La respuesta debe corresponder a WEB01 o WEB02.

Ejecute nuevamente:

`curl -s localhost:8080`

HAProxy debe enviar la nueva solicitud al siguiente servidor disponible.

---

## 8. Observar el balanceo Round Robin

Para realizar diez solicitudes consecutivas ejecute:

`for i in {1..10}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done`

El resultado esperado será similar a:

WEB01

WEB02

WEB01

WEB02

WEB01

WEB02

WEB01

WEB02

WEB01

WEB02

El orden inicial puede variar. Lo determinante es observar que ambos servidores reciben solicitudes.

---

## 9. Visualizar el servicio desde el navegador

El balanceador también puede visualizarse utilizando el navegador.

[ABRIR BALANCEADOR]({{TRAFFIC_HOST1_8080}})

Al abrir el enlace aparecerá la página entregada por uno de los servidores Nginx.

Actualice varias veces la página utilizando el navegador.

Debe observar alternativamente:

`WEB01`

y

`WEB02`

Cada actualización genera una nueva solicitud HTTP que HAProxy distribuye entre los servidores disponibles.

---

## ¿Qué se debe observar?

En las fases anteriores el cliente debía conocer directamente WEB01 o WEB02.

Ahora existe un único punto de entrada:

`HAProxy :8080`

El cliente ya no necesita conocer cuál servidor procesará la solicitud.

HAProxy toma esa decisión.

La arquitectura funciona de la siguiente manera:

                    SOLICITUD
                        |
                        v
                    HAProxy
                        |
                 Round Robin
                  /       \
                 v         v
              WEB01      WEB02

Cuando ambos servidores están disponibles, HAProxy distribuye las solicitudes entre ellos.

Esto permite repartir la carga y evita depender directamente de un único servidor web.

---

## Concepto clave: balanceo de carga

El balanceo de carga distribuye solicitudes entre múltiples servidores que ofrecen un mismo servicio.

En este laboratorio:

HAProxy = balanceador

WEB01 = servidor backend

WEB02 = servidor backend

Round Robin = algoritmo de distribución

Health Check = mecanismo de comprobación de disponibilidad

La existencia de varios servidores prepara la infraestructura para tolerar fallos.

---

## Resultado esperado

Al finalizar esta fase deben existir tres contenedores operativos:

`haproxy`

`web01`

`web02`

Las solicitudes realizadas mediante:

`localhost:8080`

deben distribuirse entre WEB01 y WEB02.

En la siguiente fase se analizará visualmente el comportamiento del balanceador y se preparará la infraestructura para las pruebas de alta disponibilidad.
