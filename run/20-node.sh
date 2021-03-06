#!/bin/bash

# ROMANESCO - NODE
# ==============================================================================
#
# Set up NodeJS and NPM under local user with NVM (Node Version Manager).


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

# set up NodeJS and NPM locally with NVM
if [ -z $(sudo -i -u ${localUser} sh -l -c "command -v node") ]
then
  echo "Node.js needs to be installed."
  echo "Setting up NVM..."

  # download nvm
  sudo -i -u $localUser sh <<EOF
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
EOF

  # add nvm path to .profile so it can be accessed by installer
  sudo -i -u $localUser sh -c "cat >>.profile" <<'EOF'

# load Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF

  # tell environment which node version to use
  sudo -i -u $localUser sh -c "cat >>.nvmrc" <<'EOF'
lts/*
EOF

  # start new session and install node + packages
  echo "Installing Node and NPM..."
  sudo -i -u $localUser sh -l <<'EOF'
nvm install --lts
nvm use --lts
npm install -g gulp-cli
EOF
else
  printf "${YELLOW}Node.js seems to be installed already:${NC}\n"
  sudo -i -u $localUser sh -l -c "command -v node"
  sudo -i -u $localUser sh -l -c "node --version"

  echo "Making sure gulp-cli is also installed..."
  if [ -z $(sudo -i -u ${localUser} sh -l -c "command -v gulp") ]
  then
    sudo -i -u $localUser sh -l -c "npm install -g gulp-cli"
  fi
fi
