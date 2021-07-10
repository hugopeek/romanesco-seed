#!/bin/bash

# ROMANESCO - PURGE
# ==============================================================================
#
# Wipe entire installations from your server and remove all traces of them.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

echo "Removing project folder: $installPath/"

if [ -d "$installPath" ]
then
  rm -rf $installPath/*
  rm -rf $installPath/.[^.] #remove 2 character hidden files, not . or ..
  rm -rf $installPath/.??* #remove hidden files with 3 characters or more
  rmdir $installPath
else
  printf "${YELLOW}Installation folder not found.${NC}\n"
fi

echo "Removing database..."

if [ -d "/var/lib/mysql/$dbName" ]
then
  mysql -e "DROP DATABASE $dbName"
else
  printf "${YELLOW}Database not found.${NC}\n"
fi

echo "Removing database user..."

mysql -e "DROP USER IF EXISTS '${dbUser}'@'localhost'"

echo "Removing NGINX server block..."

if [ -f "/etc/nginx/sites-available/$lcaseName" ]
then
  rm /etc/nginx/sites-available/$lcaseName
  rm /etc/nginx/sites-enabled/$lcaseName
else
  printf "${YELLOW}Server block not found.${NC}\n"
fi

echo "Removing php-fpm pool..."

if [ -f "/etc/php/$phpVersion/fpm/pool.d/$lcaseName.conf" ]
then
  rm /etc/php/$phpVersion/fpm/pool.d/$lcaseName.conf
  service php${phpVersion}-fpm reload
else
  printf "${YELLOW}php-fpm pool not found.${NC}\n"
fi
