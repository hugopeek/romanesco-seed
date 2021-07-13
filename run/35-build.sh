#!/bin/bash

# ROMANESCO - BUILD
# ==============================================================================
#
# Install MODX and build Romanesco data files with Gitify.
# Also creates a database if existing credentials are not defined in user input.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

echo "Starting build process..."

# create MODX config.xml
cat >$configXML <<EOF
<modx>
    <database_type>mysql</database_type>
    <database_server>localhost</database_server>
    <database>$dbName</database>
    <database_user>$dbUser</database_user>
    <database_password>$dbPass</database_password>
    <database_connection_charset>utf8mb4</database_connection_charset>
    <database_charset>utf8mb4</database_charset>
    <database_collation>utf8mb4_unicode_ci</database_collation>
    <table_prefix>modx_</table_prefix>
    <https_port>443</https_port>
    <http_host>$httpHost</http_host>
    <cache_disabled>0</cache_disabled>
    <inplace>0</inplace>
    <unpacked>0</unpacked>

    <language>$language</language>
    <cmsadmin>$userName</cmsadmin>
    <cmspassword>$userPass</cmspassword>
    <cmsadminemail>$userEmail</cmsadminemail>

    <core_path>$installPath/core/</core_path>

    <context_mgr_path>$installPath/manager/</context_mgr_path>
    <context_mgr_url>${baseURL%/}/manager/</context_mgr_url>
    <context_connectors_path>$installPath/connectors/</context_connectors_path>
    <context_connectors_url>${baseURL%/}/connectors/</context_connectors_url>
    <context_web_path>$installPath/</context_web_path>
    <context_web_url>${baseURL%/}/</context_web_url>

    <remove_setup_directory>1</remove_setup_directory>
</modx>
EOF

chown $localUser:$localUser $configXML

# install MODX
if [ "$installMODX" = y ]
then
  # exit if MySQL was not found
  type mysql >/dev/null 2>&1

  # create user and empty database
  if [ "$forceFlag" ] && [ -d "/var/lib/mysql/$dbName" ] ; then
    mysql -e "DROP DATABASE ${dbName}"
  fi
  mysql -e "CREATE DATABASE IF NOT EXISTS ${dbName} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -e "DROP USER IF EXISTS '${dbUser}'@'localhost'"
  mysql -e "CREATE USER '${dbUser}'@'localhost' IDENTIFIED BY '${dbPass}'"
  mysql -e "GRANT ALL ON ${dbName}.* TO '${dbUser}'@'localhost'"
  mysql -e "FLUSH PRIVILEGES"
  mysql -e "SHOW GRANTS FOR '${dbUser}'@'localhost'"

  echo "Database $dbName and user successfully created."

  # run gitify install
  sudo -i -u $localUser sh -c "cd $installPath && $gitifyPath/Gitify modx:install $modxVersion --config=$configXML"

  echo "You can log in to the manager using the following credentials:"
  printf "Username: ${BOLD}$userName${NORMAL}\n"
  printf "Password: ${BOLD}$userPass${NORMAL}\n"

  # adjust autoincrement values of MODX core tables
  mysql -D $dbName -u $dbUser -p$dbPass <<EOF
TRUNCATE TABLE modx_site_templates;

ALTER TABLE modx_access_actiondom AUTO_INCREMENT=100001;
ALTER TABLE modx_access_actions AUTO_INCREMENT=100001;
ALTER TABLE modx_access_category AUTO_INCREMENT=100001;
ALTER TABLE modx_access_context AUTO_INCREMENT=100001;
ALTER TABLE modx_access_elements AUTO_INCREMENT=100001;
ALTER TABLE modx_access_media_source AUTO_INCREMENT=100001;
ALTER TABLE modx_access_menus AUTO_INCREMENT=100001;
ALTER TABLE modx_access_namespace AUTO_INCREMENT=100001;
ALTER TABLE modx_access_permissions AUTO_INCREMENT=100001;
ALTER TABLE modx_access_policies AUTO_INCREMENT=100001;
ALTER TABLE modx_access_policy_template_groups AUTO_INCREMENT=100001;
ALTER TABLE modx_access_policy_templates AUTO_INCREMENT=100001;
ALTER TABLE modx_access_resource_groups AUTO_INCREMENT=100001;
ALTER TABLE modx_access_templatevars AUTO_INCREMENT=100001;

ALTER TABLE modx_actiondom AUTO_INCREMENT=100001;
ALTER TABLE modx_actions AUTO_INCREMENT=100001;
ALTER TABLE modx_actions_fields AUTO_INCREMENT=100001;

ALTER TABLE modx_categories AUTO_INCREMENT=100001;
ALTER TABLE modx_content_type AUTO_INCREMENT=100001;
ALTER TABLE modx_dashboard AUTO_INCREMENT=100001;
ALTER TABLE modx_dashboard_widget AUTO_INCREMENT=100001;
ALTER TABLE modx_document_groups AUTO_INCREMENT=100001;
ALTER TABLE modx_documentgroup_names AUTO_INCREMENT=100001;
ALTER TABLE modx_fc_profiles AUTO_INCREMENT=100001;
ALTER TABLE modx_fc_sets AUTO_INCREMENT=100001;
ALTER TABLE modx_lexicon_entries AUTO_INCREMENT=100001;
ALTER TABLE modx_media_sources AUTO_INCREMENT=100001;
ALTER TABLE modx_member_groups AUTO_INCREMENT=100001;
ALTER TABLE modx_membergroup_names AUTO_INCREMENT=100001;
ALTER TABLE modx_property_set AUTO_INCREMENT=100001;

ALTER TABLE modx_site_htmlsnippets AUTO_INCREMENT=100001;
ALTER TABLE modx_site_plugins AUTO_INCREMENT=100001;
ALTER TABLE modx_site_snippets AUTO_INCREMENT=100001;
ALTER TABLE modx_site_templates AUTO_INCREMENT=100001;
ALTER TABLE modx_site_tmplvar_access AUTO_INCREMENT=100001;
ALTER TABLE modx_site_tmplvars AUTO_INCREMENT=100001;

ALTER TABLE modx_user_group_roles AUTO_INCREMENT=100001;
EOF

  echo "Database tables successfully incremented."
fi

# install packages
if [ "$installPackages" = y ]
then

  # if a local path is defined, copy and install packages from there
  if [ "$packagesPath" ] ; then
    echo "Copying local packages to core/packages folder..."

    sudo -i -u $localUser sh -c "cat > $installPath/.rsync_exclude" <<EOF
contentblocks*
redactor*
cbheadingimage*
htmlpagedom*
romanescobackyard*
mailblocks*
resizer*
core*
EOF
    sudo -i -u $localUser rsync -av --exclude-from=$installPath/.rsync_exclude $packagesPath/*.transport.zip $installPath/core/packages
    sudo -i -u $localUser sh -c "cd $installPath && rm -f $installPath/.rsync_exclude"
    sudo -i -u $localUser sh -c "cd $installPath && $gitifyPath/Gitify package:install --local"

    # create temporary .gitify and install modmore extras
    sudo -i -u $localUser sh <<EOF1
mv $installPath/.gitify $installPath/.gitify.original
cat > $installPath/.gitify <<EOF2
packages:
    modmore.com:
        service_url: https://rest.modmore.com/
        credential_file: '.modmore.com.key'
        packages:
            - contentblocks
            - redactor
EOF2
cd $installPath && $gitifyPath/Gitify package:install --all
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF1
  else
    # otherwise, download and install all packages defined in .gitify
    sudo -i -u $localUser sh -c "cd $installPath && $gitifyPath/Gitify package:install --all"
  fi

  echo "MODX packages successfully installed."

  # adjust autoincrement values of extras tables
  mysql -D $dbName -u $dbUser -p$dbPass <<EOF
TRUNCATE TABLE modx_collection_templates;
TRUNCATE TABLE modx_collection_template_columns;

ALTER TABLE modx_clientconfig_group AUTO_INCREMENT=100001;
ALTER TABLE modx_clientconfig_setting AUTO_INCREMENT=100001;
ALTER TABLE modx_collection_settings AUTO_INCREMENT=100001;
ALTER TABLE modx_collection_template_columns AUTO_INCREMENT=100001;
ALTER TABLE modx_collection_templates AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_category AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_default AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_field AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_layout AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_template AUTO_INCREMENT=100001;
ALTER TABLE modx_contentblocks_template AUTO_INCREMENT=100001;
ALTER TABLE modx_redactor_set AUTO_INCREMENT=100001;
ALTER TABLE modx_migx_config_elements AUTO_INCREMENT=100001;
ALTER TABLE modx_migx_configs AUTO_INCREMENT=100001;
ALTER TABLE modx_migx_elements AUTO_INCREMENT=100001;
ALTER TABLE modx_migx_formtab_fields AUTO_INCREMENT=100001;
ALTER TABLE modx_migx_formtabs AUTO_INCREMENT=100001;
ALTER TABLE modx_quickstartbuttons_buttons AUTO_INCREMENT=100001;
ALTER TABLE modx_quickstartbuttons_sets AUTO_INCREMENT=100001;
EOF

  echo "Package tables successfully incremented."
fi

# build Romanesco with Gitify
if [ "$buildRomanesco" = y ] ; then
  sudo -i -u $localUser sh <<EOF
cd $installPath && git add -A
cd $installPath && git commit -m "Initial project extract"
mv $installPath/.gitify $installPath/.gitify.original
cp $installPath/_romanesco/_gitify/.gitify.romanesco_build $installPath/.gitify
cd $installPath && $gitifyPath/Gitify build
rm $installPath/.gitify
cp $installPath/_romanesco/_gitify/.gitify.defaults_build $installPath/.gitify
cd $installPath && $gitifyPath/Gitify build
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF

  # add gateway settings to web and hub contexts
  echo "Adding gateway context settings..."
  mysql -D $dbName -u $dbUser -p$dbPass -v <<EOF
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('web', 'base_url', '/', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('web', 'site_url', '${uriScheme}://${httpHost}/', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('web', 'http_host', '${httpHost}', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('hub', 'base_url', '/', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('hub', 'site_url', '${uriScheme}://hub.${httpHost}/', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('hub', 'http_host', 'hub.${httpHost}', 'textfield', 'core', 'gateway', NULL);
INSERT INTO \`$dbName\`.\`modx_context_setting\` (\`context_key\`, \`key\`, \`value\`, \`xtype\`, \`namespace\`, \`area\`, \`editedon\`) VALUES ('hub', 'site_start', '', 'textfield', 'core', 'site', NULL);
EOF
  echo "Database rows successfully added."

  # if you want to import existing content, do it at this point
  # it needs to be done before Backyard is installed (which is in the next step)

  # build Backyard resources
  sudo -i -u $localUser sh <<EOF
mv $installPath/.gitify $installPath/.gitify.original
cp $installPath/_romanesco/_gitify/.gitify.backyard_build $installPath/.gitify
cd $installPath && $gitifyPath/Gitify build
rm $installPath/.gitify
mv $installPath/.gitify.original $installPath/.gitify
EOF

  # copy local Romanesco packages not present in official repo
  for package in "${gpmPackages[@]}"
  do
    sudo -i -u $localUser sh -c "cp $package $installPath/core/packages/"
  done

  # install local packages and wrap up
  sudo -i -u $localUser sh <<EOF
cd $installPath && $gitifyPath/Gitify package:install --local

cd $installPath && $gitifyPath/Gitify extract
cd $installPath && git add -A
cd $installPath && git commit -m "Extract fresh Romanesco installation"

# apply default styling theme
cp $installPath/assets/semantic/dist/project/* $installPath/assets/semantic/dist
EOF

  printf "${GREEN}Romanesco was successfully built!${NC}\n"
fi

# some final housekeeping
echo "Clearing cache..."
rm -rf $installPath/core/cache/*

echo "Creating cache folder for images and ContentBlocks..."
sudo -i -u $localUser mkdir $installPath/assets/cache

echo "Making config file inaccessible to other users..."
chmod 0600 $installPath/core/config/config.inc.php

if [ "$npmFlag" ]
then
  echo "Building Semantic UI assets..."
  sudo -i -u $localUser sh -l -c "cd $installPath && gulp build"
  echo "Theme files updated."
fi
