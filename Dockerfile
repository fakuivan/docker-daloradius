FROM ubuntu:16.04
ARG REPO=https://github.com/lirantal/daloradius.git
ARG RELEASE

RUN apt update

# Install PHP7
RUN apt -y install  php7.0 \
                    php7.0-cli \
                    php7.0-common \
                    php7.0-curl \
                    php7.0-gd \
                    php7.0-mcrypt \
                    php7.0-mysql \
                    php-mail \
                    php-mail-mime \
                    php-pear \
                    php-db

# Install PHP Pear DB library
RUN pear install DB

# Install apache2
RUN apt -y install  apache2 \
                    libapache2-mod-php7.0

# Configure apache2 and PHP7
RUN /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf && \
    /bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini && \
    rm -rf /var/www/html/index.html

# Install git
RUN apt -y install  git

# Install daloRADIUS
RUN git clone "${REPO}" "/var/www/html" && \
    git -C "/var/www/html" checkout "${RELEASE}" && \
    chown www-data:www-data -R "/var/www/html"

# Apply patch to config file for environment variable support
ADD "./config.patch" "/config.patch"
RUN git -C "/var/www/html" apply "/config.patch"

# Add entrypoint
ADD "./entrypoint.sh" "entrypoint.sh"
ENTRYPOINT [ "./entrypoint.sh" ]

EXPOSE 80 443

CMD apachectl -D FOREGROUND
