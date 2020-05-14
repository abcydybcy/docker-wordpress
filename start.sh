#!/bin/sh
echo "Hello!"
echo "Using database $DB_NAME at $DB_USER:$(echo -n "$DB_PASS" | tr -c '' '*')@$DB_HOST"

BASEDIR=/srv
WORKDIR=$BASEDIR/wordpress
WP_CONFIG=$WORKDIR/wp-config.php
cd $BASEDIR

# If not present, install WP
if [ ! -f $WORKDIR/index.php ]; then 
	echo ":: Downloading latest wordpress..."
	curl -o /tmp/wordpress.tgz https://wordpress.org/latest.tar.gz
	tar -xf /tmp/wordpress.tgz
	rm /tmp/wordpress.tgz
fi

# Fresh config
if [ -f $WP_CONFIG ]; then
	rm $WP_CONFIG
fi
cp $WORKDIR/wp-config-sample.php $WP_CONFIG

# File perms
chown -R nginx: $WORKDIR
chmod 777 $WORKDIR

# Config
echo ":: Generating config"
cat > $WP_CONFIG << EOF
<?php
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASS' );
define( 'DB_HOST', '$DB_HOST' );
define( 'WP_HOME', 'http://$WP_HOME' );
define( 'WP_SITEURL', 'http://$WP_HOME' );

define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

# Update DB
if [ ! "x$WP_OLD_HOME" = "x" ]; then
echo ":: Updating database links"
mysql -u "$DB_USER" --password="$DB_PASS" -h "$DB_HOST" "$DB_NAME" << EOF
UPDATE wp_options SET option_value = replace(option_value, 'http://$WP_OLD_HOME', 'http://$WP_HOME') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = replace(guid, 'http://$WP_OLD_HOME','http://$WP_HOME');
UPDATE wp_posts SET post_content = replace(post_content, 'http://$WP_OLD_HOME', 'http://$WP_HOME');
UPDATE wp_postmeta SET meta_value = replace(meta_value,'http://$WP_OLD_HOME','http://$WP_HOME');
EOF
fi

# Start
echo ":: All done, spinning up."
php-fpm -y /usr/local/etc/php-fpm.conf -c /usr/local/etc/php/php.ini-production -D
nginx

echo ":: All aboard! Watching nginx error.log:"
tail -f /var/log/nginx/error.log