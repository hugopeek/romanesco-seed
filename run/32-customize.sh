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
  sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: site_name/a value: '$projectName'\" $settingsPath/site-name.yaml"
  echo "Setting client_email..."
  sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: client_email/a value: $userEmail\" $configsPath/client-email.yaml"

  # set environment PATH
  # WARNING: probably not the full path, including NPM bin!!!
  # something to do with sudoers protecting the shell...
  echo "Setting env_path..."
  sudo -i -u $localUser sh -c "echo \"value: \$PATH\" >> $settingsPath/romanesco.env-path.yaml"

  # theming
  if [ "$themeColorPrimary" ] ; then
    echo "Changing primary color..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_color_primary/a value: $themeColorPrimary\" $configsPath/theme-color-primary.yaml"
  fi
  if [ "$themeColorPrimaryLight" ] ; then
    echo "Changing primary light color..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_color_primary_light/a value: $themeColorPrimaryLight\" $configsPath/theme-color-primary-light.yaml"
  fi
  if [ "$themeColorSecondary" ] ; then
    echo "Changing secondary color..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_color_secondary/a value: $themeColorSecondary\" $configsPath/theme-color-secondary.yaml"
  fi
  if [ "$themeColorSecondaryLight" ] ; then
    echo "Changing secondary color..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_color_secondary_light/a value: $themeColorSecondaryLight\" $configsPath/theme-color-secondary-light.yaml"
  fi
  if [ "$themeFontHeader" ] ; then
    echo "Changing header font..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_font_header/a value: $themeFontHeader\" $configsPath/theme-font-header.yaml"
  fi
  if [ "$themeFontPage" ] ; then
    echo "Changing regular font..."
    sudo -i -u $localUser sh -c "sed -i -e \"/value/d\" -e \"/key: theme_font_page/a value: $themeFontPage\" $configsPath/theme-font-page.yaml"
  fi
fi

printf "${BOLD}Project settings successfully applied.${NORMAL}\n"
