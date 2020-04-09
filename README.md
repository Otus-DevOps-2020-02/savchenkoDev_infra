# savchenkoDev_infra
savchenkoDev Infra repository

### ДЗ №3
***Задание по SSH***
1. Чтобы подключиться к **someinternalhost** по **ssh** одной командой
   ```
   $ ssh -i <адрес_ключа> -t -A <имя_пользователя>@<ip_бастион_хоста> ssh <ip_внутреннего_хоста>
   ```
   например в моем случае:
   ```
   $ ssh -t -A sergejsavcenko@34.89.229.94 ssh 10.156.0.4
   ```
2. Чтобы подключиться к **someinternalhost** по алиасу надо отредактировать файл `ssh_config`

   открыть `nano ~/.ssh/config` и доавить в него следующий код
   ```
   Host bastion
        User <имя_пользователя>
        HostName <ip_бастион_хоста>
   Host someinternalhost
        HostName <ip_внутреннего_хоста>
        ProxyJump bastion (или <ip_бастион_хоста>)
   ```
   мой вариант:
   ```
   Host bastion
       User sergejsavcenko
       HostName 34.89.229.94
   Host someinternalhost
       HostName 10.156.0.4
       ProxyJump bastion
   ```

***Данные для подключения***
```
bastion_IP = 34.89.229.94
someinternalhost_IP = 10.156.0.4
```

### ДЗ №4
***Данные для подключения***
```
testapp_IP = 34.77.80.82
testapp_port = 9292
```
***Задание по созданию правила файрвола с помощью gcloud***

Чтобы создать правило файрвола через **gcloud** надо выполнить команду:
```
gcloud compute firewall-rules create default-puma-server \
  --action allow \
  --source-ranges 0.0.0.0/0 \
  --target-tags puma-server \
  --rules TCP:9292
```

Опций там намного больше я указал только те, которые были нужны мне.

***Задание по созданию инстанса со `startup-script`***

Скрипт должен объединять в себе команды используемые в `install_ruby.sh`, `install_mongodb.sh` и `deploy.sh`. Избавившись от повторяющихся действий получил:
```
#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xd68fa50fea312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```

Создать инстанс с `startup-script` можно передав скрипт напрямую в команду создания в опции `--metadata` с ключем `startup-script`.
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script="#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xd68fa50fea312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d"
Ctrl+D -> Enter
```
или передав его из локального файла в опции `--metadata-from-file=startup-script=<относительный_путь_до_файла>`
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file=startup-script=apps/otus/savchenkoDev_infra/startup-script.sh
```
Так же можно передать его с из облачного хранилища CloudStorage, для этого надо добавить опцию `--storage storage-ro` которая дает доступ виртуальной машины в Cloud Storage и `--metadata startup-script-url=<ссылка на файл>`
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --scopes storage-ro \
  --metadata startup-script-url=gs://learn-otus/startup-script.sh
```

Скрипт выполнится сразу после создания инстанса поэтому первые несколько минут (в моем случае 2-3) приложение будет не доступно


### ДЗ №6
***Задание c ключами***

Добавление ключей возможно в ресурсе `google_compute_instance` в параметре `metadata`
```
metadata = {
  ssh-keys = "appuser:<ssh key>\nappuser1:<ssh key 1>"
}
```
или через ресурс `google_compute_project_metadata_item`, значение ключей я вынес в переменную

main.tf
________
```
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = join("\n", var.ssh_keys)
}
```
variables.tf
_____
```
variable "ssh_keys" {
  description = "Public keys used for ssh access"
  default = "<default key>"
}
```

terraform.tfvars
____
```
ssh_keys = [ "<first key>", "<second key>" ]
```

После выполнения `terraform apply` ключ пользователя appuser-web, удалился из метаданных
