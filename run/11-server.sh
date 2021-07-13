#!/bin/bash

# ROMANESCO - SERVER
# ==============================================================================
#
# Generate NGINX server config in the sites-enabled folder.
# Add a separate PHP-FPM pool for local user (if needed).
# Generate and install SSL certificate with Let's Encrypt.


# CONFIG
# ==============================================================================

# exit if variable was not passed
# variables are set in romanesco parent script
set -u

# exit on any type of error
set -e


# EXECUTE
# ==============================================================================

# remove existing server block if force option is used
if [ "$forcePrepare" ] && [ -f "/etc/nginx/sites-available/$lcaseName" ]
then
  echo -e "${YELLOW}Server config already exists.${NC}"
  echo -e "Force removing old server block..."

  rm "/etc/nginx/sites-available/$lcaseName"
  rm "/etc/nginx/sites-enabled/$lcaseName"
fi

# create separate php-fpm pool
if [ "$preparePHP" ] && ! [ -f "/etc/php/${phpVersion}/fpm/pool.d/${localUser}.conf" ]
then
  echo "Adding separate php-fpm pool..."

  cat > "/etc/php/${phpVersion}/fpm/pool.d/${localUser}.conf" <<EOF
[$localUser]
user = $localUser
group = $localUser
listen = /var/run/php$phpVersion-fpm.$localUser.sock
listen.owner = www-data
listen.group = www-data
;php_admin_value[disable_functions] = exec,passthru,shell_exec,system
;php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /

; Add local binaries available on server, plus NVM bin folder.
; NVM path is a symlink, which is slightly easier to edit when NVM gets updated.
env[PATH] = /usr/local/bin:/usr/bin:/bin:$homeFolder/bin/node
EOF
fi

# create server block
if [ "$prepareNginx" ] && ! [ -f "/etc/nginx/sites-available/$lcaseName" ]
then
  echo "Adding NGINX server block..."

  cat > "/etc/nginx/sites-available/$lcaseName" <<EOF
server {
  listen                80;
  listen                [::]:80;

  server_name $projectURL www.$projectURL hub.$projectURL;

  root $installPath;
  index index.php;

  access_log            /var/log/nginx/$lcaseName.access.log;
  error_log             /var/log/nginx/$lcaseName.error.log;

  include snippets/sites-all.conf;
  include snippets/sites-modx.conf;

  # Use separate php-fpm socket
  location ~ \.php(.*)\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:$phpSocket;
  }

  # Redirect www traffic to non-www
  if (\$host = "www.$projectURL") {
    return 301 \$scheme://$projectURL\$request_uri;
  }
}
EOF

  # create symlink in sites-enabled folder
  ln -s "../sites-available/$lcaseName" "/etc/nginx/sites-enabled/$lcaseName"

  # reload
  service nginx reload
  service php${phpVersion}-fpm reload
fi

# generate and install Let's Encrypt certificate
if [ "$prepareSSL" ] && [ "$domainFlag" ]; then
  echo -e "Generating SSL certificates for domain $projectURL..."
  certbot --nginx -n -d ${projectURL},www.${projectURL},hub.${projectURL} -m ${userEmail} --agree-tos --redirect #--dry-run
fi
