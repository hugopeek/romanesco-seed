#!/bin/bash

# ROMANESCO - CUSTOMIZE
# ==============================================================================
#
# These modifications will be applied after build.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

echo "Applying a few more customizations..."

# create temporary homepage
if [ "$buildRomanesco" = y ] && [ "$welcomePage" ]
then
  echo "Creating welcome page..."

  rm $installPath/_data/content/web/index.html
  sudo -i -u $localUser cp $welcomePage $installPath/_data/content/web/index.html

  # create temporary .gitify and build page
  sudo -i -u $localUser sh <<EOF1
mv $installPath/.gitify $installPath/.gitify.original
cat > $installPath/.gitify <<EOF2
data_directory: _data/
backup_directory: _backup/

data:
    content:
        type: content
        exclude_keys:
            - editedby
            - editedon
        where:
            - 'context_key:IN': [web]
            - 'AND:alias:IN': [index]
EOF2
cd $installPath && $gitifyPath/Gitify build
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF1
fi

# activate SMTP settings
#if [ "$buildRomanesco" = y ]
#then
#  echo "Activating email capabilities..."
#fi
