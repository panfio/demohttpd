# demohttpd

Билд контейнера `docker build ./website/ -t website:v1`

Запуск контейнера `docker run -d -p 80:80 website`

Остановка, очистка всех контейнеров и images

```console
docker stop $(sudo docker ps -a | grep website | awk '{print $1}')
docker rm -f $(sudo docker ps -a | grep website | awk '{print $1}')
docker rmi -f $(sudo docker images | grep website | awk '{print $3}')
```

Чтобы настроить сервер Jenkins, необходимо настроить aws cli и запустить конфигурацию из `/terraform/jenkins/`. Файл `/terraform/data/aws_launch_configuration_jenkins` содержит Launch configuration сервера Jenkins с установленным Ansible, Docker Registry, Terraform и Consul как бэкэнд для terraform.

```console
cd /terraform/jenkins/
terraform init
terraform plan
terraform apply
```

================================
```
$ cat /var/log/cloud-init-output.log
$ cat /var/lib/jenkins/secrets/initialAdminPassword
```
