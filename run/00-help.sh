#!/bin/bash

# exit if variable was not passed
set -u

# exit on any type of error
set -e

# USAGE
# ==============================================================================

echo "Usage: ./romanesco [TASK] [SUBJECT] [--OPTION] for project [PROJECT_NAME] [--ARGS]"
echo "Example: ./romanesco plant seed for project 'Romanesco' -d romanesco.info"
echo ""
echo "You can define multiple subjects per task: 'prepare nginx php-fpm ssl'"
echo "You can also chain tasks together with 'and': 'prepare everything and plant seed'"
echo ""
echo "By default, a new database is created by the installer (requires ~/.my.cnf"
echo "file with root credentials). If this option is unavailable to you, you"
echo "need to create the database manually (or use an existing one) and provide"
echo "its credentials by appending 'in database' + arguments to the command."
echo ""
echo "Available tasks, subjects and options:"
echo "    prepare"
echo "      user*             create local Linux user + home folder"
echo "      nginx*            add server config to sites-available"
echo "      php-fpm*          add separate php-fpm pool for local user"
echo "      ssl*              generate SSL certificate with Let's Encrypt"
echo "      node              install node.js + npm with NVM"
echo "      everything*       perform all of the above"
echo "      -f|--force        remove existing data first"
echo "    plant"
printf "${BOLD}"
echo "      seed              create a new Romanesco project"
printf "${NORMAL}"
echo "      -n|--npm          install frontend dependencies with npm"
echo "      -f|--force        remove existing data first"
echo "    purge"
echo "      server*           remove Nginx server block and php-fpm pool"
echo "      database          remove MySQL database + user"
echo "      files             remove project folder"
echo "      everything*       remove all of the above"
echo "    for project"
echo "      [PROJECT_NAME]    wrap in '' if name consists of multiple words"
echo "      -p|--path PATH              default: ${wwwPath}/project-name"
echo "      -d|--domain DOMAIN          default: project-name.${domainExt}"
echo "      -u|--username USERNAME      default: ${defaultUser}"
echo "      -s|--password PASSWORD      default: {generated}"
echo "      -e|--email EMAIL            default: ${defaultEmail}"
echo "      -l|--language EN            default: ${defaultLanguage:-EN}"
echo "      -a|--admin        create separate admin user"
echo "    in database"
echo "      -n|--dbname DATABASE"
echo "      -u|--dbuser USERNAME"
echo "      -s|--dbpass PASSWORD"
echo ""
echo "*requires sudo privileges"
