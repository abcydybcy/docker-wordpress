Releases with `*-onstart` tag download latest Wordpress on start, the rest have verion baked in from the day of the build.

Volumes:  
  - Wordpress mount point: `/srv/wordpress`: `-v your/wp/files:/srv/wordpress`

Environment variables:
  - `DB_HOST`: Database host
  - `DB_NAME`: Database name
  - `DB_USER`: Database user
  - `DB_PASS`: Database password
  - `WP_HOME`: FQDN/IP to use in Wordpress
  - `WP_OLD_HOME`: Old WP_HOME value, when specified URLs in the database will be updated with the new value.