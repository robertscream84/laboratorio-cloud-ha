# Laboratorio completado

## Balanceo de carga y alta disponibilidad

Se ha completado la construcción y experimentación de una infraestructura distribuida utilizando Ubuntu, Docker, Nginx y HAProxy.

La práctica comenzó con un entorno vacío y progresivamente incorporó una red privada, múltiples servidores web y un balanceador de carga.

La arquitectura final alcanzada fue:

                    USUARIO
                       |
                       v
                  +----------+
                  | HAProxy  |
                  |   :8080  |
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

---

## ¿Qué se comprobó?

Durante el laboratorio se observó experimentalmente que HAProxy puede distribuir solicitudes entre múltiples servidores utilizando Round Robin.

Cuando WEB01 fue detenido, el balanceador detectó que el servidor dejó de responder y retiró temporalmente ese backend de la rotación.

WEB02 continuó atendiendo las solicitudes.

Por consiguiente, la falla de un servidor no provocó la interrupción completa del servicio.

Posteriormente WEB01 fue recuperado y HAProxy volvió a incorporarlo automáticamente.

Finalmente, la incorporación de WEB03 permitió observar cómo una infraestructura puede incrementar su capacidad mediante **escalabilidad horizontal**.

---

## Conceptos consolidados

Al finalizar la práctica se han experimentado los siguientes conceptos:

**Balanceo de carga:** distribución del tráfico entre múltiples servidores.

**Redundancia:** existencia de más de un componente capaz de proporcionar el mismo servicio.

**Health Check:** mecanismo utilizado para comprobar si un servidor continúa disponible.

**Resiliencia:** capacidad de continuar prestando el servicio cuando ocurre una falla.

**Alta disponibilidad:** diseño orientado a reducir interrupciones mediante redundancia, supervisión y mecanismos de recuperación.

**Escalabilidad horizontal:** incorporación de nuevas instancias para aumentar la capacidad del sistema.

---

## Una observación crítica

La infraestructura construida todavía contiene un punto único de falla:

`HAProxy`

Los servidores web son redundantes, pero el balanceador no lo es.

Si HAProxy dejara de funcionar, los usuarios perderían el punto de acceso al servicio.

Una infraestructura de producción podría resolver esta limitación mediante múltiples balanceadores, failover, IP virtual, zonas de disponibilidad o servicios de balanceo administrados por un proveedor cloud.

---

## Reflexión final

Antes de finalizar, el estudiante debería poder responder:

1. ¿Qué diferencia existe entre balanceo de carga y alta disponibilidad?
2. ¿Por qué WEB02 pudo mantener disponible el servicio cuando WEB01 falló?
3. ¿Qué función desempeñaron los health checks?
4. ¿Por qué HAProxy representa todavía un punto único de falla?
5. ¿Qué diferencia existe entre escalabilidad vertical y horizontal?
6. ¿Qué efecto produjo agregar WEB03?
7. ¿Cómo podría mejorarse esta arquitectura para utilizarla en producción?

---

## Resultado alcanzado

El laboratorio permitió pasar de servidores aislados a una infraestructura distribuida capaz de:

`Distribuir tráfico`

↓

`Detectar fallos`

↓

`Excluir servidores no disponibles`

↓

`Mantener el servicio`

↓

`Recuperar servidores`

↓

`Incrementar capacidad`

Comprender esta secuencia resulta determinante para interpretar cómo funcionan muchas arquitecturas modernas desplegadas en centros de datos y plataformas cloud.

## Fin del laboratorio

La práctica ha finalizado correctamente.
