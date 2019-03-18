# demohttpd

Билд контейнера `docker build ./website/ -t website:v1`

Запуск контейнера `docker run -d -p 80:80 website`

Чтобы настроить сервер Jenkins, необходимо войти в aws cli и запустить конфигурацию из `/terraform/jenkins/`. Файл `/terraform/data/aws_launch_configuration_jenkins` содержит Launch configuration сервера Jenkins с установленным Ansible, Docker Registry, Terraform и Consul как бэкэнд для terraform.

```
cd /terraform/jenkins/
terraform init
terraform plan
terraform apply -auto-approve

ssh -i jenkins_server.pem ec2-user@52.71.77.123
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Предполагается, что у docker registry неизменяемый ip-адрес, поэтому необходимо указать адрес `{INSECURE_REGISTRY}` и применить скрипт на всех инстансах с docker после создания нового registry сервера

```
INSECURE_REGISTRY=
sudo echo "${INSECURE_REGISTRY} myregistry" >> /etc/hosts
sudo cat <<EOF >/etc/docker/daemon.json
{
  "insecure-registries" : [ "http://${INSECURE_REGISTRY}:5000" ],
  "experimental" : true
}
EOF
sudo echo "DOCKER_OPTS="--insecure-registry 54.162.21.94:5000"" >> /etc/default/docker
systemctl daemon-reload && service docker restart
```

## Jenkins project

На Jenkins сервере создаем пустой проект, в настройках проекта вставляем ссылку на гит-репо, помечаем триггер при коммите. Далее в shell билдим контейнеры, и отправляем в registry.

```
docker build -t website:v1.$BUILD_ID /var/lib/jenkins/workspace/dada/website
docker tag website:v1.$GIT_COMMIT 54.162.21.94:5000/website:v1.$GIT_COMMIT
docker tag website:v1.$GIT_COMMIT 54.162.21.94:5000/website:latest
docker push 54.162.21.94:5000/$JOB_NAME:v1.$GIT_COMMIT
docker push 54.162.21.94:5000/$JOB_NAME:latest
````

Перед деплоем контейнеров, создать выполнение shell скрипта на создание/обновление ресурсов. Необходимо настроить aws cli или IAM роль для EC2 с нужными policy.

```
cd /var/lib/jenkins/workspace/dada/terraform/website
terraform init
terraform apply -auto-approve
```

Деплоим с помощью ansible. Необходимо указать `docker_registry` в group_vars и хосты в инвентори.

```
cd /var/lib/jenkins/workspace/dada/ansible
ansible-playbook rundeploy.yaml
```

Чистим после билдов всех контейнеров и images

```
docker stop $(sudo docker ps -a | grep website | awk '{print $1}')
docker rm -f $(sudo docker ps -a | grep website | awk '{print $1}')
docker rmi -f $(sudo docker images | grep website | awk '{print $3}')
```
================================

# Not implemented yet

На сервере БД запустить скрипт на создание тестовой базы

```
sudo -u postgres /usr/pgsql-10/bin/psql -c "CREATE USER testuser;"
sudo -u postgres /usr/pgsql-10/bin/psql -c "ALTER USER testuser WITH ENCRYPTED password 'testuser';"
sudo -u postgres /usr/pgsql-10/bin/psql -c "CREATE DATABASE testdb OWNER testuser;"

```

```
sudo cat /etc/docker/daemon.json
$ cat /var/log/cloud-init-output.log
$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword

[ec2-user@ip-172-31-90-203 ~]$ sudo vi /usr/lib/systemd/system/docker.service
[ec2-user@ip-172-31-90-203 ~]$ sudo systemctl daemon-reload && sudo service docker restart

--insecure-registry 3.83.114.1:5000 \
vi /usr/lib/systemd/system/docker.service
ExecStart=/usr/bin/dockerd --insecure-registry 192.168.127.1:5000


docker login -u "qwerty" -p "qwerty" http://3.83.114.1:5000
echo "qwerty" | docker login -u "qwerty" --password-stdin http://3.83.114.1:5000

```
