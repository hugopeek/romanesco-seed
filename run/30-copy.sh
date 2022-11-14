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

# create project folder
if [ "$forcePlant" ] && [ -d "$installPath" ]
then
  echo -e "${YELLOW}Folder already exists.${NC}"
  echo -e "Force overwriting..."
  rm -rf "${installPath}"/*
  rm -rf "${installPath}"/.[^.] #remove 2 character hidden files, not . or ..
  rm -rf "${installPath}"/.??* #remove hidden files with 3 characters or more
  rmdir "${installPath}"
elif ! [ "$forcePlant" ] && [ -d "$installPath" ]
then
  echo -e "${YELLOW}Folder already exists.${NC}"
  echo -e "Use the force Luke (-f), or remove the folder manually."
  echo -e "${RED}Abort.${NC}"
  exit 0
else
  sudo -i -u $localUser sh -c "mkdir $installPath"
fi

echo "Installation folder successfully created."

if [ "$copyPackages" = y ] && [ "$gpmPath" ]
then
  echo "Checking dependencies..."

  # create package folder if needed
  if ! [ -d "$gpmPath" ] ; then
    sudo -i -u $currentUser sh -c "mkdir -p $gpmPath"
  fi

  # clone / update source repositories
  i="0"
  for repository in "${gpmRepos[@]}"
  do
    project=${gpmProjects[$i]}
    if ! [ -d "$gpmPath/$project" ] ; then
      sudo -i -u $currentUser sh -c "git clone $repository $gpmPath/$project"
    else
      sudo -i -u $currentUser sh -c "cd $gpmPath/$project && git pull"
    fi
    i=$(($i+1))
  done

  # grab the latest package versions
  for project in "${gpmProjects[@]}"
  do
    pkgFolder="$gpmPath/$project/_packages"
    pkgVersion=$(ls -v ${pkgFolder} | tail -n 1)
    gpmPackages+=("${pkgFolder}/$pkgVersion")
  done
fi

if [ "$copyFiles" = y ]
then
  echo "Cloning Romanesco repositories..."

  # prevent dubious ownership warning
  sudo -i -u $localUser sh -c "git config --global --add safe.directory $installPath"

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
