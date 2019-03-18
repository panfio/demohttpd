# demohttpd

Билд контейнера `docker build ./website/ -t website:v1`

Запуск контейнера `docker run -d -p 80:80 website`

Остановка, очистка всех контейнеров и images

```
docker stop $(sudo docker ps -a | grep website | awk '{print $1}')
docker rm -f $(sudo docker ps -a | grep jenkins | awk '{print $1}')
docker rmi -f $(sudo docker images | grep jenkins | awk '{print $3}')
```

Чтобы настроить сервер Jenkins, необходимо войти в aws cli и запустить конфигурацию из `/terraform/jenkins/`. Файл `/terraform/data/aws_launch_configuration_jenkins` содержит Launch configuration сервера Jenkins с установленным Ansible, Docker Registry, Terraform и Consul как бэкэнд для terraform.

```
cd /terraform/jenkins/
terraform init
terraform plan
terraform apply -auto-approve
```

Предполагается, что у docker registry неизменяемый ip-адрес, поэтому необходимо указать адрес `INSECURE_REGISTRY` и применить скрипт на всех инстансах с docker после создания нового registry сервера

```
sudo echo "3.83.114.1 myregistry" >> /etc/hosts
```

На Jenkins сервере в настройках проекта, перед деплоем контейнеров, создать выполнение shell скрипта на создание/обновление ресурсов.

```
cd /var/lib/jenkins/workspace/dada/terraform/website
terraform init
terraform apply -auto-approve
```
================================
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

/etc/docker/daemon.json
sudo cat <<EOF >/etc/docker/daemon.json
{
    "insecure-registries" : [ "http://35.153.142.183:5000" ],
    "storage-driver": "overlay"
}
EOF
sudo systemctl restart docker


--insecure-registry 3.83.114.1:5000 \
vi /usr/lib/systemd/system/docker.service
ExecStart=/usr/bin/dockerd --insecure-registry 192.168.127.1:5000

And now reset docker:

systemctl daemon-reload && service docker restart
sudo systemctl daemon-reload && sudo service docker restart

docker login -u "qwerty" -p "qwerty" http://3.83.114.1:5000
echo "qwerty" | docker login -u "qwerty" --password-stdin http://3.83.114.1:5000


docker push 13.57.222.61:5000/website-resume
    8  sudo docker tag e9810eadafcf gitlab.example.com:5000/website-resume
    9  docker push gitlab.example.com:5000/website-resume
   12  sudo docker tag e2130627a325 gitlab.example.com:5000/my-apache
   13  docker push gitlab.example.com:5000/my-apache

sudo yum install -y  https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-redhat10-10-2.noarch.rpm
sudo sed -i "s/rhel-\$releasever-\$basearch/rhel-latest-x86_64/g" "/etc/yum.repos.d/pgdg-10-redhat.repo"
sudo yum install -y postgresql10
sudo /usr/pgsql-10/bin/postgresql-10-setup initdb
sudo systemctl start postgresql-10 && sudo systemctl enable postgresql-10

sudo -u postgres /usr/pgsql-10/bin/psql -c "DROP DATABASE sonar;"
sudo -u postgres /usr/pgsql-10/bin/psql -c "DROP USER sonar;"

sudo docker build -t $JOB_NAME:v1.$BUILD_ID /home/ansadmin/playbooks/target/
sudo docker tag $JOB_NAME:v1.$BUILD_ID dockerregistry:5000/$JOB_NAME:v1.$BUILD_ID

sudo docker tag $JOB_NAME:v1.$BUILD_ID dockerregistry:5000/$JOB_NAME:latest

sudo docker push dockerregistry:5000/$JOB_NAME:v1.$BUILD_ID

sudo docker push dockerregistry:5000/$JOB_NAME:latest

sudo docker rmi $JOB_NAME:v1.$BUILD_ID dockerregistry:5000/$JOB_NAME:v1.$BUILD_ID dockerregistry:5000/$JOB_NAME:latest
```
