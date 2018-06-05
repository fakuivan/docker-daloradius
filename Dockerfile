FROM ubuntu:16.04

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

# Install git, feel free to change these
RUN apt -y install  git && \
    git config --global user.email "fakuivan@gmail.com" && \
    git config --global user.name  "fakuivan"

# Install daloRADIUS
ENV DR_FILES="/root/daloradius"
ENV DR_SOURCE="${DR_FILES}/source"
ENV DR_SUBMOD="${DR_SOURCE}/source"
ENV DR_CONFIG_PATCH="${DR_FILES}/config.patch"

ADD "." "${DR_SOURCE}"
ADD "./config.patch" "${DR_CONFIG_PATCH}"
## Apply patch to config file for environment variable support
RUN git -C "${DR_SUBMOD}" apply "${DR_CONFIG_PATCH}"
## Copy repository
RUN stash_name="$(git -C "${DR_SUBMOD}" stash create)" && \
    git -C "${DR_SUBMOD}" archive --format=tar "$stash_name" | tar -x -C "/var/www/html"
## Set correct permissions
RUN chown www-data:www-data -R "/var/www/html"

# Add entrypoint
ADD "./entrypoint.sh" "/daloradius-entrypoint.sh"
ENTRYPOINT [ "/daloradius-entrypoint.sh" ]

EXPOSE 80 443

CMD apachectl -D FOREGROUND
