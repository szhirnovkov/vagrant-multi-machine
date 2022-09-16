#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Примечания:
#   В конце каждой команды вы можете увидеть > / dev / null . Это просто подавляет вывод из процессов установки.
#   Если вы хотите увидеть результат при подготовке, просто удалите его.
#   Когда вы пытаетесь установить пакет с помощью команды apt-get install , он всегда запрашивает подтверждение, 
#   флаг -y указывает «да», поэтому он не будет запрашивать подтверждение каждой установки.

echo -e "\e[34m Adding virtual host $ServerName \e[0m"

echo "<VirtualHost *:80>" > /etc/apache2/sites-available/$ServerName.conf
echo "  ServerAdmin $ServerAdmin" >> /etc/apache2/sites-available/$ServerName.conf
echo "  ServerName $ServerName" >> /etc/apache2/sites-available/$ServerName.conf
echo "  ServerAlias $ServerAlias" >> /etc/apache2/sites-available/$ServerName.conf
echo "  DocumentRoot $DocumentRoot" >> /etc/apache2/sites-available/$ServerName.conf
echo "  ErrorLog ${APACHE_LOG_DIR}/error.log" >> /etc/apache2/sites-available/$ServerName.conf
echo "  CustomLog ${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/sites-available/$ServerName.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/$ServerName.conf
