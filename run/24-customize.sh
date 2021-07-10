#!/bin/bash

# ROMANESCO - CUSTOMIZE
# ==============================================================================
#
# This script replaces some of the default settings with project information.
# The changes are made in the Gitify config files and will be applied on build.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

echo "Customizing project settings..."

# change system and configuration settings
if [ "$buildRomanesco" = y ]
then
  echo "Setting site_name..."
  sed -i -e "/value/d" -e "/key: site_name/a value: '$projectName'" $settingsPath/site-name.yaml
  echo "Setting client_email..."
  sed -i -e "/value/d" -e "/key: client_email/a value: $userEmail" $configsPath/client-email.yaml
  #echo "Setting custom_cache..."
  #sed -i -e "/value/d" -e "/key: custom_cache/a value: '1'" $configsPath/custom-cache.yaml
fi

if [ "$themeColorPrimary" ]
then
  echo "Changing primary color..."
  sed -i -e "/value/d" -e "/key: theme_color_primary/a value: $themeColorPrimary" $configsPath/theme-color-primary.yaml
fi

if [ "$themeColorPrimaryLight" ]
then
  echo "Changing secondary color..."
  sed -i -e "/value/d" -e "/key: theme_color_primary_light/a value: $themeColorPrimaryLight" $configsPath/theme-color-primary-light.yaml
fi

printf "${bold}Project settings successfully applied.${normal}\n"
