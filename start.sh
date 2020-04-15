#!/bin/sh
echo "Hello!"
echo "Using database $DB_NAME at $DB_USER:$DB_PASS@$DB_HOST"

echo ":: Downloading latest wordpress..."
curl -o /tmp/wordpress.tgz https://wordpress.org/latest.tar.gz
tar -xf /tmp/wordpress.tgz
rm /tmp/wordpress.tgz

mv /srv/wordpress/wp-config-sample.php /srv/wordpress/wp-config.php
chown -R nginx: /srv/wordpress

# Inject database config into wp-config
echo ":: Injecting database config"
WP_CONFIG=/srv/wordpress/wp-config.php
sed -i "s/localhost/$DB_HOST/" $WP_CONFIG
sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG
sed -i "s/username_here/$DB_USER/" $WP_CONFIG
sed -i "s/password_here/$DB_PASS/" $WP_CONFIG

# Start
php-fpm -y /usr/local/etc/php-fpm.conf -c /usr/local/etc/php/php.ini-production -D
nginx
tail -f /var/log/nginx/access.log