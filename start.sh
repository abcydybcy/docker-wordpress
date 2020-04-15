#!/bin/sh
echo "Hello!"
echo "Using database $DB_NAME at $DB_USER:$DB_PASS@$DB_HOST"

# Inject database config into wp-config
WP_CONFIG=/srv/wordpress/wp-config.php
sed -i "s/localhost/$DB_HOST/" $WP_CONFIG
sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG
sed -i "s/username_here/$DB_USER/" $WP_CONFIG
sed -i "s/password_here/$DB_PASS/" $WP_CONFIG

# Start
php-fpm -y /usr/local/etc/php-fpm.conf -c /usr/local/etc/php/php.ini-production -D
nginx
tail -f /var/log/nginx/access.log