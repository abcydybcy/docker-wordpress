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
echo ":: Injecting database config"
sed -i "s/localhost/$DB_HOST/" $WP_CONFIG
sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG
sed -i "s/username_here/$DB_USER/" $WP_CONFIG
sed -i "s/password_here/$DB_PASS/" $WP_CONFIG

echo ":: Provided WP_HOME address is $WP_HOME"
echo "define( 'WP_HOME', 'http://$WP_HOME' );" >> $WP_CONFIG
echo "define( 'WP_SITEURL', 'http://$WP_HOME' );" >> $WP_CONFIG

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