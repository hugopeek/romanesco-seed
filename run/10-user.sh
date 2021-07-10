#!/bin/bash

# ROMANESCO - USER
# ==============================================================================
#
# Create local Linux user and isolate this user in its own usergroup.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

if [[ -z $(getent passwd ${localUser}) ]] && [[ -z $(getent group ${localUser}) ]]
then
  echo "Creating local user..."

  # create user and user group + home folder with the same name
  useradd -r -U -m -s /bin/sh $localUser

  # add Gitlab to known hosts, to avoid manual confirmation when cloning repositories
  mkdir -p $homeFolder/.ssh/
  ssh-keygen -H -F gitlab.com >> $homeFolder/.ssh/known_hosts || true
  chown $localUser:$localUser $homeFolder/.ssh/known_hosts
  chmod 644 $homeFolder/.ssh/known_hosts
fi