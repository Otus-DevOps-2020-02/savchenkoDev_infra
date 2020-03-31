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
