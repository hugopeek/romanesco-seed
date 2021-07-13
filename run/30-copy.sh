#!/bin/bash

# ROMANESCO - COPY
# ==============================================================================
#
# Clone required repositories and create essential project files.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

echo "Starting installation..."

# create project folder
if [ "$forceFlag" ] && [ -d "$installPath" ]
then
  echo -e "${YELLOW}Folder already exists.${NC}"
  echo -e "Force overwriting..."
  rm -rf "${installPath}"/*
  rm -rf "${installPath}"/.[^.] #remove 2 character hidden files, not . or ..
  rm -rf "${installPath}"/.??* #remove hidden files with 3 characters or more
  rmdir "${installPath}"
elif ! [ "$forceFlag" ] && [ -d "$installPath" ]
then
  echo -e "${YELLOW}Folder already exists.${NC}"
  echo -e "Use the force Luke (-f), or remove the folder manually."
  echo -e "${RED}Abort.${NC}"
  exit 0
else
  mkdir $installPath
  chown $localUser:$localUser $installPath
fi

echo "Installation folder successfully created."

if [ "$copyPackages" = y ] && [ "$gpmPath" ]
then
  echo "Cloning dependencies..."

  for repository in "${gpmRepos[@]}"
  do
    sudo -i -u $localUser "git clone $repository $gpmPath"
  done

  # grab the latest package versions
  for project in "${gpmProjects[@]}"
  do
    gpmPackages+=("$(ls -v ${gpmPath}/${project}/_packages | tail -n 1)")
  done

  for package in "${gpmPackages[@]}"
  do
    echo $package
  done
fi

if [ "$copyFiles" = y ]
then
  echo "Cloning Romanesco repositories..."

  # clone Romanesco repositories
  sudo -i -u $localUser git clone "$gitPathSoil" "$installPath"
  sudo -i -u $localUser git clone "$gitPathData" "$installPathData"
  sudo -i -u $localUser git clone "$gitPathTheme" "$installPathTheme"

  # unset remote, so it's a separate project from now on
  cd $installPath && git remote remove origin

  # set git user info for this repository
  sudo -i -u $localUser sh -c "cd $installPath && git config user.email \"$userEmail\""
  sudo -i -u $localUser sh -c "cd $installPath && git config user.name \"$localUser\""

  echo "Git repositories successfully cloned."

  # create modmore.com key file
  sudo -i -u $localUser cat > $installPath/.modmore.com.key <<EOF
username: $modmoreUser
api_key: $modmoreAPIkey
EOF

  #chmod 440 $installPath/.modmore.com.key
  echo "File .modmore.com.key successfully created."

  # create .gitify
  if [ -d "$installPath/_romanesco" ]
  then
    sudo -i -u $localUser cp $installPath/_romanesco/_gitify/.gitify.project $installPath/.gitify
    echo "Gitify config file successfully created."
  else
    echo -e "${YELLOW}Romanesco data folder could not be found.${NC}"
  fi
fi

# run NPM install
if [ "$npmFlag" ]
then
  sudo -i -u $localUser sh -l -c "cd $installPath && npm install"
  echo "NPM dependencies successfully installed."
fi
