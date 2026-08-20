# Fase 3 - Servidor WEB01

## Objetivo de aprendizaje

En esta fase se desplegará el primer servidor web del laboratorio utilizando Nginx.

WEB01 estará conectado a la red privada `lab-net` creada anteriormente.

## 1. Crear el contenido de WEB01

Ejecute:

`mkdir -p /tmp/web01`

Ahora cree la página:

`echo '<html><body style="font-family:Arial;text-align:center;margin-top:80px"><h1>WEB01</h1><h2>Servidor Nginx operativo</h2><p>Laboratorio de Alta Disponibilidad</p></body></html>' > /tmp/web01/index.html`

## 2. Crear WEB01

Ejecute:

`docker run -d --name web01 --network lab-net -v /tmp/web01:/usr/share/nginx/html:ro nginx:alpine`

Docker descargará la imagen Nginx la primera vez. Esto puede tardar algunos segundos.

## 3. Comprobar el servidor

Ejecute:

`docker ps`

Debe aparecer:

WEB01 | nginx:alpine | Up

## 4. Consultar su dirección IP

Ejecute:

`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web01`

Anote la dirección IP obtenida.

## 5. Probar WEB01

Ejecute:

`curl http://web01`

Debe aparecer el contenido HTML correspondiente a WEB01.

## ¿Qué se debe observar?

WEB01 funciona como un servidor independiente conectado a la red privada.

El nombre `web01` puede utilizarse para comunicarse con el servidor sin conocer previamente su dirección IP.

Esto será especialmente útil cuando HAProxy necesite localizar los servidores backend.

## Resultado esperado

WEB01 debe encontrarse operativo y responder solicitudes HTTP.
