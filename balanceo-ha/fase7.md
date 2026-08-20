
# Fase 7 - Prueba de resiliencia y alta disponibilidad

## Objetivo de aprendizaje

En esta fase se provocará intencionalmente la caída de uno de los servidores web para comprobar cómo responde una infraestructura redundante ante una falla.

El estudiante observará cómo HAProxy detecta que WEB01 deja de estar disponible y evita enviar nuevas solicitudes hacia ese servidor.

El objetivo fundamental es comprobar experimentalmente que la falla de un servidor no implica necesariamente la caída del servicio.

---

## 1. Comprobar el estado inicial

Antes de provocar la falla, ejecute:

`docker ps`

Deben encontrarse operativos:

`haproxy`

`web01`

`web02`

La infraestructura inicial debe presentar:

                    HAProxy
                       |
                 +-----+-----+
                 |           |
                 v           v
              WEB01        WEB02
                UP            UP

---

## 2. Comprobar el balanceo antes de la falla

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done | sort | uniq -c`

El resultado esperado será aproximadamente:

`10 WEB01`

`10 WEB02`

Esto establece una referencia antes de provocar la falla.

Ambos servidores están participando en la atención de solicitudes.

---

## 3. Simular la falla de WEB01

Ahora se provocará intencionalmente una falla.

Ejecute:

`docker stop web01`

Este comando detiene completamente el servidor WEB01.

No se modificará HAProxy.

Tampoco se cambiará manualmente la configuración del balanceador.

---

## 4. Comprobar el estado de los servidores

Ejecute:

`docker ps -a`

Debe observar:

`haproxy` → Up

`web01` → Exited

`web02` → Up

La infraestructura ahora presenta:

                    HAProxy
                       |
                 +-----+-----+
                 |           |
                 v           v
              WEB01        WEB02
               DOWN           UP
                 X             |
                               |
                               v
                         Servicio activo

---

## 5. Comprobar si el servicio continúa disponible

Ejecute:

`curl -s localhost:8080`

La solicitud debe continuar respondiendo correctamente.

La respuesta debe provenir de:

`WEB02`

Esto demuestra que la caída de WEB01 no provocó la interrupción completa del servicio.

---

## 6. Generar múltiples solicitudes

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done`

El resultado debe mostrar únicamente:

WEB02

WEB02

WEB02

WEB02

...

HAProxy ya no debe enviar solicitudes hacia WEB01.

---

## 7. Medir la distribución durante la falla

Ejecute:

`for i in {1..20}; do curl -s localhost:8080 | grep -o 'WEB0[12]' | head -1; done | sort | uniq -c`

El resultado esperado será:

`20 WEB02`

Antes de la falla existía aproximadamente:

WEB01 = 50 %

WEB02 = 50 %

Después de la falla:

WEB01 = 0 %

WEB02 = 100 %

---

## 8. Observar los logs de HAProxy

Ejecute:

`docker logs haproxy --tail 30`

Busque mensajes relacionados con:

`web01`

HAProxy utiliza comprobaciones de estado para determinar si los servidores backend continúan disponibles.

La configuración:

`server web01 web01:80 check`

permite comprobar periódicamente la disponibilidad de WEB01.

Cuando el servidor deja de responder, HAProxy lo retira temporalmente del conjunto de servidores disponibles.

---

## 9. Probar desde el navegador

Abra nuevamente el servicio:

[ABRIR SERVICIO BALANCEADO]({{TRAFFIC_HOST1_8080}})

Actualice varias veces la página.

Aunque WEB01 se encuentra detenido, la página debe continuar funcionando.

Todas las solicitudes deben mostrar:

`WEB02`

La dirección utilizada por el usuario no cambia.

El usuario continúa accediendo al mismo balanceador.

---

## ¿Qué se debe observar?

Antes de provocar la falla:

                    HAProxy
                       |
                  Round Robin
                   /       \
                  v         v
               WEB01      WEB02
                 UP         UP
                50 %       50 %

Después de detener WEB01:

                    HAProxy
                       |
                  Health Check
                   /       \
                  v         v
               WEB01      WEB02
                DOWN        UP
                  X         |
                            |
                            v
                         100 %

El balanceador detecta que WEB01 no se encuentra disponible y deja de enviar solicitudes hacia él.

WEB02 continúa procesando el tráfico.

---

## ¿Por qué el servicio no se cayó?

La aplicación dispone de más de una instancia capaz de responder las solicitudes.

HAProxy conoce el estado de los servidores mediante los health checks.

Por esta razón, cuando WEB01 deja de estar disponible, las nuevas solicitudes se redirigen hacia WEB02.

El usuario continúa utilizando:

`HAProxy :8080`

sin necesidad de conocer qué servidor está funcionando internamente.

---

## Concepto clave: resiliencia

La resiliencia representa la capacidad de una infraestructura para continuar prestando un servicio cuando alguno de sus componentes presenta una falla.

En este experimento:

`WEB01 falla`

pero:

`WEB02 continúa operativo`

y:

`HAProxy redirige el tráfico`

Por lo tanto:

`El servicio permanece disponible`

---

## Alta disponibilidad y punto único de falla

El laboratorio demuestra redundancia en la capa de servidores web.

Sin embargo, todavía existe un componente único:

`HAProxy`

Si HAProxy falla, el servicio completo dejaría de estar disponible.

Por esta razón, una arquitectura de alta disponibilidad real puede incorporar también múltiples balanceadores, mecanismos de failover, réplicas distribuidas y diferentes zonas de disponibilidad.

Este laboratorio representa una arquitectura simplificada diseñada para comprender los principios fundamentales.

---

## Resultado esperado

Al finalizar esta fase debe comprobarse experimentalmente que:

* WEB01 se encuentra detenido.
* WEB02 continúa operativo.
* HAProxy detecta la falla.
* HAProxy deja de enviar tráfico hacia WEB01.
* WEB02 recibe el 100 % de las solicitudes.
* La dirección utilizada por el cliente no cambia.
* El servicio web continúa disponible.

En la siguiente fase WEB01 será recuperado y se observará cómo HAProxy vuelve a incorporarlo automáticamente al conjunto de servidores disponibles.
