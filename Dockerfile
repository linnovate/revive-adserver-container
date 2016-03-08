FROM phusion/baseimage:0.9.16

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libapache2-mod-php5 php5-mcrypt php5-mysql php5-curl php5-gd

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

RUN php5enmod mcrypt mysql curl gd

RUN a2enmod php5 rewrite

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir /revive
RUN curl -L https://github.com/revive-adserver/revive-adserver/archive/v3.2.3.tar.gz | tar -zx -C /revive --strip-components=1

ADD plugins /revive/
ADD var-plugins/plugins /revive/var/

RUN chown -R www-data:www-data /revive/var

RUN find /revive/var -type d -exec chmod 700 {} +
RUN find /revive/var -type f -exec chmod 600 {} +
RUN chmod 700 /revive/var

RUN chown -R www-data:www-data /revive/plugins
RUN chown -R www-data:www-data /revive/www/admin/plugins
RUN chmod 700 /revive/www/admin/plugins

ADD default.conf.php /revive/var/default.conf.php 
ADD configure /srv/configure
RUN chown root:root /srv/configure
RUN chmod 700 /srv/configure

WORKDIR /revive

EXPOSE 80
CMD ["/usr/bin/supervisord"]
