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
cd $installPath && $gitifyCmd build
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF1
fi

# activate SMTP settings
#if [ "$buildRomanesco" = y ]
#then
#  echo "Activating email capabilities..."
#fi

# prepare project for updating itself
if [ "$buildRomanesco" = y ]
then
  echo "Teach project how to update itself..."
  sudo -i -u $localUser sh -c "mkdir -p $operationsPath"
  sudo -i -u $localUser sh -c "cp ${seedPath}/config.sh $operationsPath"

  # append local project variables to config
  cat >> "$operationsPath/config.sh" <<EOF


# PROJECT
# ==============================================================================

# Local project variables
installPath=$installPath
projectName="$projectName"
lcaseName=$lcaseName
projectURL=$projectURL

EOF

  # copy operations base config
  sudo -i -u $localUser sh <<EOF
cp $installPathData/_operations/operations.sh $operationsPath/operations.sh

# symlink operations scripts (using relative paths!)
cd $installPath
ln -s ./_operations/operations.sh operations
chmod +x operations
ln -s ./../_romanesco/_operations/run ./_operations
ln -s ./../_romanesco/_operations/tools ./_operations

# install dependencies
cd $operationsPath && composer install
EOF
fi