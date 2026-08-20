# Fase 4 - Servidor WEB02

## Objetivo de aprendizaje

En esta fase se desplegará un segundo servidor web Nginx.

WEB02 tendrá contenido diferente a WEB01 para que sea posible identificar visualmente qué servidor procesa cada solicitud.

## 1. Crear el contenido de WEB02

Ejecute:

`mkdir -p /tmp/web02`

Ahora cree la página:

`echo '<html><body style="font-family:Arial;text-align:center;margin-top:80px"><h1>WEB02</h1><h2>Servidor Nginx operativo</h2><p>Laboratorio de Alta Disponibilidad</p></body></html>' > /tmp/web02/index.html`

## 2. Crear WEB02

Ejecute:

`docker run -d --name web02 --network lab-net -v /tmp/web02:/usr/share/nginx/html:ro nginx:alpine`

## 3. Verificar los servidores

Ejecute:

`docker ps`

Deben aparecer:

- web01
- web02

ambos con estado `Up`.

## 4. Consultar la dirección IP de WEB02

Ejecute:

`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web02`

## 5. Probar WEB02

Ejecute:

`docker run --rm --network lab-net curlimages/curl http://web02`

Debe aparecer:

`WEB02`

## 6. Comparar ambos servidores

Ejecute:

`docker run --rm --network lab-net curlimages/curl -s http://web01`

Después:

`docker run --rm --network lab-net curlimages/curl -s http://web02`

## ¿Qué se debe observar?

WEB01 y WEB02 ofrecen el mismo servicio, pero son componentes independientes.

Cada servidor tiene:

- su propio nombre;
- su propia dirección IP;
- su propio proceso Nginx;
- su propio contenido web.

En la siguiente fase HAProxy utilizará ambos servidores como backends.

## Resultado esperado

WEB01 y WEB02 deben responder correctamente desde la red `lab-net`.
