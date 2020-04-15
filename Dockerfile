FROM php:7.2-fpm-alpine
LABEL name="wordpress-nginx"
LABEL description="Wordpress with nginx/php7.2/php-fpm on Alpine linux"
WORKDIR /srv

# Dependencies
COPY --chown=root:root wordpress.conf /etc/nginx/conf.d/
COPY --chown=root:root start.sh /opt/

RUN apk add curl tar nginx php-mysqlnd;\
	docker-php-ext-install mysqli;\
	docker-php-ext-enable mysqli;\
	mkdir -p /run/nginx;\
	rm /etc/nginx/conf.d/default.conf;\
	chmod +x /opt/start.sh;

ENTRYPOINT sh /opt/start.sh
EXPOSE 80/tcp