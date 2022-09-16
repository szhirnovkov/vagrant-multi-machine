#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Примечания:
#   В конце каждой команды вы можете увидеть > / dev / null . Это просто подавляет вывод из процессов установки.
#   Если вы хотите увидеть результат при подготовке, просто удалите его.
#   Когда вы пытаетесь установить пакет с помощью команды apt-get install , он всегда запрашивает подтверждение, 
#   флаг -y указывает «да», поэтому он не будет запрашивать подтверждение каждой установки.

echo -e "\e[34m Create DB $DBNAME \e[0m"
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DBNAME"
sudo mysql -u root -e "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASSWD'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'%'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DB_ROOT_USER'@'localhost'"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

