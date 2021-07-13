#!/bin/bash

# ROMANESCO - PERMISSIONS
# ==============================================================================
#
# Create separate admin account and apply limited permissions to specified user.
# This comes in handy if you're automating installation and want to give limited
# access to end user immediately.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# FUNCTIONS
# ==============================================================================

genpasswd() {
  local l=$1
  [ "$l" == "" ] && l=16
  tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}


# VARIABLES
# ==============================================================================

adminPass="$(genpasswd 13)"
passwdSalt="$(date | md5sum)"
passwdSalt="${passwdSalt// -/}"
export adminPass="${adminPass}"
export passwdSalt="${passwdSalt}"
passwdHash="$(perl -e 'print crypt("$ENV{adminPass}", "\$1\$$ENV{passwdSalt}\$"),"\n"')"


# EXECUTE
# ==============================================================================

echo "Setting custom permissions..."

# create admin user
if [ "$buildRomanesco" = y ] && [ "$adminFlag" ]
then
  echo "Creating admin user..."

  # create _data files for Gitify
  sudo -i -u $localUser sh -c "mkdir -p $installPath/_data/users"
  sudo -i -u $localUser sh -c "cat > $installPath/_data/users/2.yaml" <<EOF
id: 2
username: $defaultUser
password: ${passwdHash}
hash_class: hashing.modNative
salt: ${passwdSalt}
primary_group: 1
sudo: 1
createdon: $(date +%s)
EOF
  sudo -i -u $localUser sh -c "mkdir -p $installPath/_data/user_attributes"
  sudo -i -u $localUser sh -c "cat > $installPath/_data/user_attributes/2.yaml" <<EOF
id: 2
internalKey: 2
fullname: $defaultUser
email: $defaultEmail
EOF
  sudo -i -u $localUser sh -c "mkdir -p $installPath/_data/member_groups"
  sudo -i -u $localUser sh -c "cat > $installPath/_data/member_groups/2.yaml" <<EOF
id: 2
user_group: 1
member: 2
role: 2
EOF

  # create temporary .gitify and add user
  sudo -i -u $localUser sh <<EOF1
mv $installPath/.gitify $installPath/.gitify.original
cat > $installPath/.gitify <<EOF2
data_directory: _data/
backup_directory: _backup/

data:
    member_groups:
        class: modUserGroupMember
        primary: id
    user_attributes:
        class: modUserProfile
        primary: id
        exclude_keys:
            - sessionid
    users:
        class: modUser
        primary:
            - id
        exclude_keys:
            - cachepwd
            - remote_key
            - remote_data
            - session_stale
EOF2
cd $installPath && $gitifyCmd build --no-cleanup
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF1

  # no-one will ever know we were here
  sudo -i -u $localUser sh -c "rm -f $installPath/_data/users/2.yaml"
  sudo -i -u $localUser sh -c "rm -f $installPath/_data/user_attributes/2.yaml"
  sudo -i -u $localUser sh -c "rm -f $installPath/_data/member_groups/2.yaml"
fi

# change permissions for user account
if [ "$buildRomanesco" = y ] && [ "$adminFlag" ]
then
  echo "Set correct permissions for end user..."

  # create _data files for Gitify
  sudo -i -u $localUser sh -c "cat > $installPath/_data/users/1.yaml" <<EOF
id: 1
primary_group: 2
sudo: 0
EOF
  sudo -i -u $localUser sh -c "cat > $installPath/_data/member_groups/1.yaml" <<EOF
id: 1
user_group: 2
member: 1
role: 3
EOF

  # create temporary .gitify and add user
  sudo -i -u $localUser sh <<EOF1
mv $installPath/.gitify $installPath/.gitify.original
cat > $installPath/.gitify <<EOF2
data_directory: _data/
backup_directory: _backup/

data:
    member_groups:
        class: modUserGroupMember
        primary: id
    users:
        class: modUser
        primary:
            - id
        exclude_keys:
            - username
            - password
            - cachepwd
            - remote_key
            - remote_data
            - hash_class
            - salt
            - session_stale
            - createdon
EOF2
cd $installPath && $gitifyCmd build --no-cleanup
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF1

  # no-one will ever know we were here
  sudo -i -u $localUser sh -c "rm -f $installPath/_data/users/1.yaml"
  sudo -i -u $localUser sh -c "rm -f $installPath/_data/member_groups/1.yaml"
fi

# return login credentials
echo "You can log in to the MODX manager using the following credentials:"
printf "Username: ${BOLD}$userName${NORMAL}\n"
printf "Password: ${BOLD}$userPass${NORMAL}\n"
