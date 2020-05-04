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

### ДЗ №7
***Задание про `storage-bucket`***

Чтобы настроить хранение в бэкэнде надо добавить модуль `storage-bucket` и выходную переменную в файле `main.tf`
```
module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.1"
  name = "state-remote-storage"
  location = var.region
}
output storage-bucket_url {
  value = module.storage-bucket.url
}
```
потом в папках окружений создать файл `backend.tf`
___
```
terraform {
  backend "gcs" {
    bucket = "state-remote-storage"
    prefix = "<окружение>"
  }
}
```
потом надо в папках окружений запустить получение модудей `terraform get` и `terraform init`

Это настроит стейт файла в удаленном бекенде

***Задание  про `provisioners`***

Так как инстансы разворачиваются из образов с уже установленным софтом надо только скачать код приложения и запустить puma-server
В `modules/app/main.tf` добавить
___
```
provisioner "file" {
  source      = "${path.module}/puma.service"
  destination = "/tmp/puma.service"
}
provisioner "remote-exec" {
  script = "${path.module}/deploy.sh"
}
```
и скопировать файлы в директорию

**Чтобы инстанс приложение мог подключится к БД надо добавить сервису переменную окружения `DATABASE_URL`**
1. Добавить выходную переменную в модуле db и объявить ее в модуле app
`outputs.tf`

```
output "db_internal_ip" {
  value = google_compute_instance.reddit-db.network_interface[0].network_ip
}
```
`modules/app/variables.tf`
```
variable database_url {
  description = "MongoDB URL"
}
```
___
2. Сохранить в файле с переменными окружения и скопировать его на инстанс
`modules/app/main.tf`
```
provisioner "local-exec" {
  command = "echo DATABASE_URL=$DATABASE_URL >> /tmp/app.env"
  environment = {
    DATABASE_URL = var.database_url
  }
}
provisioner "file" {
  source      = "/tmp/app.env"
  destination = "/home/appuser/vars"
}
```
___
3. Добавить в `puma.service` указание откуда брать переменные окружения
```
[Unit]
...

[Service]
...
EnvironmentFile=path/to/environment/vars

[Install]
...
```
___
Все остальное настроено


### ДЗ №9

***Задание со звездочкой***

Для динамической инвентори выбрал  официальный плагин [gcp_compute](https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html)

Условия:

- Должен быть создан сервисный аккаунт в GCP
- Установлены компоненты для авторизации ansible в GCP для python

```
pip3 install requests
pip3 install google-auth
```

Далее надо создать инвентори в формате описанном в документации
```
# inventory.compute.gcp.yml

plugin: gcp_compute
projects:
  - infra-272611
zones:
  - europe-west1-b
keyed_groups:
    - key: name
groups: # по каким критериям будем группировать
  app: "'reddit-app' in name"
  db: "'reddit-db' in name"
hostnames:
  - name
compose: № как соотносить хост и адрес
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
filters: []
auth_kind: serviceaccount # способ авторизации
service_account_file: ~/service_key.json # ссылка на ключ от сервисного аккаунта
```

Потом надо в `ansible.cfg` подключить модуль `gcp_compute`
```
# ansible.cfg
...
[inventory]
enable_plugins = gcp_compute
```
Проверяем работу инвентори
```
ansible-inventory -i inventory.compute.gcp.yml --graph
```
Дальше надо передать ip инстанса с БД в приложение, для этого в файле `db_config.j2` заменим значение переменной окружения
```
DATABASE_URL={{ hostvars[groups['db'][0]]['ansible_host'] }}
```

***Задание с Packer***

Заменил скрипты на плэйбуки Ansible в образах Packer. Стоклнулся с двумя проблемами:
- пришлось заменить `ssh_username` на `root`
- передал доп параметр `force: yes` в плэйбуке для mongodb
Вот сами плэйбуки:
- packer_app.yml
```
---
- name: Install Ruby && Bundler
  hosts: all
  become: true
  tasks:
  - name: Install Ruby and Bundler
    apt: "name={{ item }} state=present"
    with_items:
      - ruby-full
      - ruby-bundler
      - build-essential
```
- packer_db.yml
```
---
- name: Install MongoDB
  hosts: all
  become: true
  tasks:
  - name: Add key
    apt_key:
      id: EA312927
      keyserver: keyserver.ubuntu.com
  - name: Add repository
    apt_repository:
      repo: deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
      state: present
  - name: Install mongodb
    apt:
      name: mongodb-org
      state: present
      force: yes
  - name: Start mongodb
    systemd:
      name: mongod
      enabled: yes
```

Далее пересоздал образы `packer`, создал  новые инстансы с помощью `terraform`, прокатил на нх `absible`. Все `success`.


### ДЗ №10

***Самостоятельное задание***

После добавления роли `jdauphant.nginx` необходимо открыть 80 порт. Для этого в файл `terraform/modules/app/main.tf` надо добавить новый ресурс GCP
```
resource "google_compute_firewall" "firewall_nginx" {
  name    = "allow-nginx-default-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
```
Добавил вызов новой роли в `./playbooks/app.yml`
```
- name: Configure App
  hosts: app
  become: true

  roles:
    - app
    - jdauphant.nginx
```

После этого обновил инфраструктуру terrafrom и проверил работоспособность. Все success

***Задание со звездочкой***

Динамическую инвентори я сделал в прошлом ДЗ.

Для начала убрал динамический адрес из файла `db_config.j2`
```
DATABASE_URL={{ db_host }}
```
Добавил в файлы `group_vars/app` переменную `db_host` со значением из динамической инвентори
```
db_host: "{{hostvars[groups['db'][0]]['ansible_host']}}"
```
Разделил инвентори для окружений. В `ansible.cfg` добавил инвентори по умолчанию для stage окружения

В самих инвентори добавил окружение в правило группировки хостов.

Пересоздал инфраструктуру terraform и прогнал плэйбук site.yml для stage окружения чтобы проверить работоспособность
