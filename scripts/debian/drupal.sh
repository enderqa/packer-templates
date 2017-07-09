#!/bin/bash

# Fully update the system
sudo apt-get update
sudo apt-get -y -q --force-yes upgrade

# Install software
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password aSimplePass0'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password aSimplePass0'

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q --force-yes install mariadb-server mariadb-client php5-mysql php5 php5-curl php5-gd apache2 libapache2-mod-php5 git

sudo bash -c 'cat > /root/.my.cnf <<EOF 
[client]
password="aSimplePass0"
EOF'

# apache2 needs to configured, stopping for now
sudo systemctl stop apache2

# download composer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo mv -v composer.phar /usr/local/bin/composer

# download drush
sudo mkdir -p /opt/drush-8.x
cd /opt/drush-8.x
sudo composer init --require=drush/drush:8.* -n
sudo composer config bin-dir /usr/local/bin
sudo composer install

# download drupal (assumes user is named vagrant!)
umask 0002
sudo chmod 777 /var/www
##drush dl -y drupal-8 --destination=/var/www/ --drupal-project-rename=drupal 
##drush dl -y drupal-7 --destination=/var/www/ --drupal-project-rename=drupal 
sudo chown vagrant:www-data /var/www/drupal
sudo chmod g+sw /var/www/drupal
sudo chmod 755 /var/www

# Apache2 configuration
sudo a2enmod rewrite ssl

sudo systemctl restart apache2
