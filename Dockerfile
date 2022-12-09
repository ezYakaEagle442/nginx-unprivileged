
# docker build --build-arg --no-cache -t "nginx-unprivileged" -f Dockerfile .
# docker login -u "myusername" -p "mypassword" docker.io
# docker tag nginx-unprivileged pinpindock/nginx-unprivileged
# docker push pinpindock/nginx-unprivileged

# docker tag nginx-unprivileged acrfootoo.azurecr.io/nginx-unprivileged
# az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd
# docker push acrfoototo.azurecr.io/nginx-unprivileged
# docker pull acrfoototo.azurecr.io/nginx-unprivileged

# docker image ls
# docker run -it -p 1025:1025 nginx-unprivileged
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>
# docker inspect nginx-unprivileged  '{{ ..[0].Config.ExposedPorts }}'
# docker images --filter reference=nginx-unprivileged --format "{{.Tag}}"

# https://hub.docker.com/_/nginx/
# https://hub.docker.com/r/nginxinc/nginx-unprivileged
# https://github.com/nginxinc/docker-nginx-unprivileged/blob/main/stable/debian/Dockerfile

# https://github.com/nginxinc/docker-nginx-unprivileged/pkgs/container/nginx-unprivileged/56194842?tag=latest
# nginx-unprivileged:latest-amd64
FROM ghcr.io/nginxinc/nginx-unprivileged:latest 

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="Nginx container Image as non root with a customer port 1025 by default"

RUN mkdir /tmp/app

#http://nginx.org/en/docs/beginners_guide.html
# By default, the configuration file is named nginx.conf and placed in the directory 
# /usr/local/nginx/conf, /etc/nginx, or /usr/local/etc/nginx.

# /§\ DEFAULT_CONF_FILE="/etc/nginx/conf.d/default.conf"
COPY index2.html /usr/share/nginx/html
COPY dashboard.html /usr/share/nginx/html
COPY demo-index.html /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /tmp/nginx
RUN touch /tmp/nginx/nginx.pid

EXPOSE ${NGINX_PORT}
CMD ["nginx", "-g", "daemon off;"]