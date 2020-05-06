FROM php:7.2-fpm-alpine
WORKDIR /srv/wordpress

# Download wp
RUN apk add curl tar nginx php-mysqlnd;\
	curl -o /tmp/wordpress.tgz https://wordpress.org/latest.tar.gz;\
	tar -xf /tmp/wordpress.tgz;\
	rm /tmp/wordpress.tgz;\
	apk del curl tar
RUN chown -R www-data: wordpress

# packages
RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable mysqli

# nginx conf
COPY --chown=root:root wordpress.conf /etc/nginx/conf.d/
COPY --chown=root:root nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /run/nginx
RUN rm /etc/nginx/conf.d/default.conf

# start script
COPY --chown=root:root start.sh /opt/
RUN chmod +x /opt/start.sh

ENTRYPOINT sh /opt/start.sh
EXPOSE 80/tcp