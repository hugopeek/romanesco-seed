#!/bin/bash

# ROMANESCO - PURGE
# ==============================================================================
#
# Wipe an entire installation from your server and remove all traces of it.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

# remove installation folder
if [ -d "$installPath" ]
then
  echo "Removing project folder: $installPath/"
  rm -rf "$installPath"/*
  rm -rf "$installPath"/.[^.] #remove 2 character hidden files, not . or ..
  rm -rf "$installPath"/.??* #remove hidden files with 3 characters or more
  rmdir "$installPath"
else
  printf "${YELLOW}Installation folder not found:${NC}\n"
  echo "$installPath"/
fi

# remove database + user
if [ -d "/var/lib/mysql/$dbName" ]
then
  echo "Removing database..."
  mysql -e "DROP DATABASE IF EXISTS ${dbName}"
  echo "Removing database user..."
  mysql -e "DROP USER IF EXISTS '${dbUser}'@'localhost'"
else
  printf "${YELLOW}Database not found.${NC}\n"
fi

# remove NGINX server block
if [ -f "/etc/nginx/sites-available/$lcaseName" ]
then
  echo "Removing NGINX server block..."
  rm "/etc/nginx/sites-available/$lcaseName"
  rm "/etc/nginx/sites-enabled/$lcaseName"
else
  printf "${YELLOW}Server block not found.${NC}\n"
fi

# remove PHP-FPM pool
if [ -f "/etc/php/$phpVersion/fpm/pool.d/$lcaseName.conf" ]
then
  echo "Removing php-fpm pool..."
  rm "/etc/php/$phpVersion/fpm/pool.d/$lcaseName.conf"
  service "php${phpVersion}-fpm reload"
else
  printf "${YELLOW}PHP-FPM pool not found.${NC}\n"
fi
