#!/bin/sh
echo "Hello!"
echo "Using database $DB_NAME at $DB_USER:$(echo $DB_PASS | tr -c '' '*')@$DB_HOST"

# Inject database config into wp-config
WP_CONFIG=/srv/wordpress/wp-config.php
sed -i "s/localhost/$DB_HOST/" $WP_CONFIG
sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG
sed -i "s/username_here/$DB_USER/" $WP_CONFIG
sed -i "s/password_here/$DB_PASS/" $WP_CONFIG

if [ ! "x$WP_HOME" = "x" ]; then  # If $WP_HOME not empty
	echo ":: Provided WP_HOME address is $WP_HOME"
	echo "define( 'WP_HOME', 'http://$WP_HOME' );" >> $WP_CONFIG
	echo "define( 'WP_SITEURL', 'http://$WP_HOME' );" >> $WP_CONFIG
fi

# Start
echo ":: All done, spinning up."
php-fpm -y /usr/local/etc/php-fpm.conf -c /usr/local/etc/php/php.ini-production -D
nginx

echo ":: All aboard! Watching nginx error.log:"
tail -f /var/log/nginx/error.log