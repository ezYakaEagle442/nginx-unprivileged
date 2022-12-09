# nginx-unprivileged
Nginx container Image as non root with a customer port 1025 by default

## Docker Build

## Set Environment variables and Config files
```sh
# https://nginx.org/en/docs/faq/variables_in_config.html
export NGINX_PORT=1025
envsubst < Dockerfile > deploy/Dockerfile
envsubst < nginx-unprivileged.yaml > deploy/nginx-unprivileged.yaml
envsubst < nginx-unprivileged_svc.yaml > deploy/nginx-unprivileged_svc.yaml

# envsubst < nginx.conf > deploy/nginx.conf
cp nginx.conf deploy/nginx.conf
sed -i "s/\$NGINX_PORT/$NGINX_PORT/g" "deploy/nginx.conf"
```

## Docker Build
```sh
# https://hub.docker.com/r/nginxinc/nginx-unprivileged
# https://github.com/nginxinc/docker-nginx-unprivileged/blob/main/stable/debian/Dockerfile

# https://github.com/nginxinc/docker-nginx-unprivileged/pkgs/container/nginx-unprivileged/56194842?tag=latest
# nginx-unprivileged:latest-amd64
# docker pull nginxinc/nginx-unprivileged

docker build --build-arg --no-cache -t "nginx-unprivileged" -f deploy/Dockerfile .
docker image ls
docker run -it -p ${NGINX_PORT}:${NGINX_PORT} --env NGINX_PORT=${NGINX_PORT} nginx-unprivileged
docker inspect nginx-unprivileged '{{ ..[0].Config.ExposedPorts }}'
docker container ls
```

## Test from inside the container or from your browser
```sh

nginx -t
cat /etc/nginx/nginx.conf
nginx -s reload

curl -X GET http://localhost:1025/index.html
curl -X GET http://host.docker.internal:1025/index.html
curl -X GET http://127.0.0.1:1025/index.html

curl -X GET http://host.docker.internal:1025/index2.html
curl -X GET http://host.docker.internal:1025/demo-index.html
```


## Docker Push
```sh
docker login -u "myusername" -p "mypassword" docker.io
docker tag nginx-unprivileged "myusername"/nginx-unprivileged
docker push "myusername"/nginx-unprivileged # https://hub.docker.com/r/pinpindock/nginx-unprivileged

#docker tag nginx-unprivileged acrfootoo.azurecr.io/nginx-unprivileged
#az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd
#docker push acrfoototo.azurecr.io/nginx-unprivileged
#docker pull acrfoototo.azurecr.io/nginx-unprivileged
```


## Deploy to K8S

https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/

```sh
kubectl create service clusterip nginx-unprivileged --tcp=${NGINX_PORT}:${NGINX_PORT} --dry-run=client -o yaml > nginx-unprivileged_svc.yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables
kubectl apply -f deploy/nginx-unprivileged_svc.yaml

#kubectl create deployment nginx-unprivileged --image=nginx-unprivileged --replicas=1 --port=80 --dry-run=client -o yaml > nginx-unprivileged.yaml
#kubectl create configmap cm-cfg --from-literal=nginx.port=${NGINX_PORT}
#kubectl describe cm cm-cfg
kubectl apply -f deploy/nginx-unprivileged.yaml
kubectl get po,deploy
kubectl describe deploy nginx-unprivileged

# https://www.jsonquerytool.com/
podname=$(kubectl get po -l app=nginx-unprivileged -o=jsonpath={.items..metadata.name})
podip=$(kubectl get po -l app=nginx-unprivileged -o=jsonpath={.items[0].status.podIP})
podport=$(kubectl get po -l app=nginx-unprivileged -o=jsonpath={.items[0].spec.containers[0].ports[0].containerPort})

echo "podname=$podname"
echo "podip=$podip"
echo "podport=$podport"

kubectl describe po $podname
kubectl get svc -o wide
kubectl exec -it $podname -- sh
kubectl logs $podname
```

## Test from inside the container deployed to K8S :
```sh
# https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/
service nginx status
# service nginx start
# service nginx stop
# service nginx stop && service nginx-debug start

nginx -t
cat /etc/nginx/nginx.conf
nginx -s reload
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful

curl -X GET http://localhost:1025/index.html
curl -X GET http://host.docker.internal:1025/index.html
curl -X GET http://127.0.0.1:1025/index.html

curl -X GET http://10.2.0.72:1025

curl -X GET http://host.docker.internal:1025/index2.html
curl -X GET http://host.docker.internal:1025/demo-index.html
```


https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-with-custom-container-image?tabs=azure-cli#prerequisites

/!\ IMPORTANT:  The web application must listen on port 1025 for Standard tier and on port 8080 for Enterprise tier. The way to change the port depends on the framework of the application. For example, specify SERVER_PORT=1025 for Spring Boot applications or ASPNETCORE_URLS=http://+:1025/ for ASP.Net Core applications.


```sh
az spring app deploy \
   --resource-group rg-iac-asa-petclinic-mic-srv \
   --name nginx-unprivileged \
   --env NGINX_PORT=1025 \
   --container-image pinpindock/nginx-unprivileged \
   --service asa-petcliasa \
   --disable-probe true \
   --language-framework "" \
   --disable-validation true
   # --container-command /bin/sh

az spring app logs --name nginx-unprivileged -s asa-petcliasa -g rg-iac-asa-petclinic-mic-srv

```
   