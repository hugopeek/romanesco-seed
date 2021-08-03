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
  echo "Setting CSS assets version..."
  sed -i -e "/value/d" -e "/key: romanesco.assets_version_css/a value: '1.0.0'" $settingsPath/romanesco.assets_version_css.yaml
  echo "Setting JS assets version..."
  sed -i -e "/value/d" -e "/key: romanesco.assets_version_js/a value: '1.0.0'" $settingsPath/romanesco.assets_version_js.yaml
  echo "Setting client_email..."
  sed -i -e "/value/d" -e "/key: client_email/a value: $userEmail" $configsPath/client-email.yaml
  echo "Setting custom_cache..."
  sed -i -e "/value/d" -e "/key: custom_cache/a value: '0'" $configsPath/custom-cache.yaml
  echo "Setting minify_css_js..."
  sed -i -e "/value/d" -e "/key: minify_css_js/a value: '0'" $configsPath/minify_css_js.yaml
  echo "Setting cache_buster..."
  sed -i -e "/value/d" -e "/key: cache_buster/a value: '0'" $configsPath/cache_buster.yaml

  # theming
  if [ "$themeColorPrimary" ] ; then
    echo "Changing primary color..."
    sed -i -e "/value/d" -e "/key: theme_color_primary/a value: $themeColorPrimary" $configsPath/theme-color-primary.yaml
  fi
  if [ "$themeColorPrimaryLight" ] ; then
    echo "Changing primary light color..."
    sed -i -e "/value/d" -e "/key: theme_color_primary_light/a value: $themeColorPrimaryLight" $configsPath/theme-color-primary-light.yaml
  fi
  if [ "$themeColorSecondary" ] ; then
    echo "Changing secondary color..."
    sed -i -e "/value/d" -e "/key: theme_color_secondary/a value: $themeColorSecondary" $configsPath/theme-color-secondary.yaml
  fi
  if [ "$themeColorSecondaryLight" ] ; then
    echo "Changing secondary color..."
    sed -i -e "/value/d" -e "/key: theme_color_secondary_light/a value: $themeColorSecondaryLight" $configsPath/theme-color-secondary-light.yaml
  fi
  if [ "$themeFontHeader" ] ; then
    echo "Changing header font..."
    sed -i -e "/value/d" -e "/key: theme_font_header/a value: $themeFontHeader" $configsPath/theme-font-header.yaml
  fi
  if [ "$themeFontPage" ] ; then
    echo "Changing regular font..."
    sed -i -e "/value/d" -e "/key: theme_font_page/a value: $themeFontPage" $configsPath/theme-font-page.yaml
  fi
fi

printf "${BOLD}Project settings successfully applied.${NORMAL}\n"
