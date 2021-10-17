#!/bin/bash

# ROMANESCO - GITIFY
# ==============================================================================
#
# Install Gitify, a command line toolkit for managing MODX sites.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

# make sure Composer is available
if [ -z $(sudo -i -u ${localUser} sh -l -c "command -v composer") ]
then
  echo "Composer needs to be installed first."
  sudo -u $localUser sh <<'EOF'
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php
RESULT=$?
rm composer-setup.php
exit $RESULT
EOF

  # make available to local user as 'composer' command
  sudo -i -u $localUser sh -c "mkdir -p ~/.local/bin"
  sudo -i -u $localUser sh -c "mv $seedPath/composer.phar ~/.local/bin/composer"
fi

# install Gitify for project, if there's no global Gitify available
if [ -z $(sudo -i -u ${localUser} sh -l -c "command -v $gitifyCmd") ]
then
  echo "Installing Gitify..."
  sudo -i -u $localUser sh <<EOF
export PATH=$HOME/.local/bin:$PATH
cd $operationsPath
composer config minimum-stability alpha
composer require modmore/gitify:^2
EOF
  printf "${GREEN}Gitify successfully installed.${NC}\n"
  sudo -i -u $localUser sh -l -c "$gitifyCmd --version"
else
  printf "${YELLOW}Gitify seems to be installed already:${NC}\n"
  sudo -i -u $localUser sh -l -c "command -v $gitifyCmd"
  sudo -i -u $localUser sh -l -c "$gitifyCmd --version"
fi