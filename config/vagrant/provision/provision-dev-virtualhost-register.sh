#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Примечания:
#   В конце каждой команды вы можете увидеть > / dev / null . Это просто подавляет вывод из процессов установки.
#   Если вы хотите увидеть результат при подготовке, просто удалите его.
#   Когда вы пытаетесь установить пакет с помощью команды apt-get install , он всегда запрашивает подтверждение, 
#   флаг -y указывает «да», поэтому он не будет запрашивать подтверждение каждой установки.

echo -e "\e[34m Register, add into /etc/hosts \e[0m"

for vhFile in /etc/apache2/sites-available/*.conf
do
    vhConf=${vhFile##*/}
    # регистрируем хост
    sudo a2ensite ${vhConf}
    vhost=${vhConf%.*}
    # Добавляем запись в /etc/hosts
    sudo sed -i "2i${vmip}    ${vhost}" /etc/hosts
done

# Обновляем настройки без перезапуска службы 
sudo systemctl reload apache2

mkdir -p /var/www/wordpress.local
mkdir -p /var/www/drupal.local

wget https://ru.wordpress.org/latest-ru_RU.tar.gz -O ./wp.tar.gz -q
tar -xf ./wp.tar.gz -C /var/www
mv /var/www/wordpress/* /var/www/wordpress.local
rm ./wp.tar.gz
rm -Rf /var/www/wordpress
cp  /var/www/wp-config.php /var/www/wordpress.local/
wget https://api.wordpress.org/secret-key/1.1/salt/ -q -O - >> /var/www/wordpress.local/wp-config.php


wget https://www.drupal.org/download-latest/tar.gz -O ./drupal.tar.gz -q
tar -xf ./drupal.tar.gz -C /var/www
mv /var/www/drupal-*/* /var/www/drupal.local
rm ./drupal.tar.gz
rm -Rf /var/www/drupal-*
cp -Rf /var/www/drupal.settings.php /var/www/drupal.local/sites/default/
php -r "echo 'return ' . bin2hex(openssl_random_pseudo_bytes(10)) . ';';" > /var/www/drupal.local/sites/default/hash_salt.php
      
# Перезапускаем Apache (останавливаем, а затем запускаем службу)
sudo service apache2 restart

