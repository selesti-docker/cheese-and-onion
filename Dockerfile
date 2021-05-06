# Based on: https://github.com/1and1internet/ubuntu-16-apache-php-7.2
FROM 1and1internet/ubuntu-16-apache
LABEL maintainer="developers+docker@selesti.com"

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=8.0

### Install required apt packages

RUN apt-get update -y --fix-missing --no-install-recommends
RUN apt-get install -y \
    graphicsmagick \
    imagemagick \
    python-software-properties \
    software-properties-common

RUN add-apt-repository -y -u ppa:ondrej/php && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get update -y

RUN apt-get install -y \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dba \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-odbc \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sqlite \
    php${PHP_VERSION}-tidy \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-xsl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-imagick \
    php-gnupg \
    php-streams \
    php-fxsl \
    git

### Configure PHP

RUN sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/${PHP_VERSION}/apache2/php.ini
RUN sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/${PHP_VERSION}/apache2/php.ini
RUN sed -i -e 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php/${PHP_VERSION}/apache2/php.ini
RUN sed -i -e 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/${PHP_VERSION}/apache2/php.ini
RUN sed -i -e 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g' /etc/apache2/mods-available/dir.conf
RUN sed -i -r 's/MaxConnectionsPerChild\s+0/MaxConnectionsPerChild   ${MAXCONNECTIONSPERCHILD}/' /etc/apache2/mods-available/*
RUN sed -i -e 's/^session.gc_probability = 0/session.gc_probability = 1/' \
    -e 's/^session.gc_divisor = 1000/session.gc_divisor = 100/' /etc/php/${PHP_VERSION}/*/php.ini

### Install Composer

RUN mkdir /tmp/composer/ && \
    cd /tmp/composer && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    cd / && \
    rm -rf /tmp/composer

### Install Node

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

### Allow unprivileged users to run PHP/Apache and access the web root

RUN chmod 777 -R /var/www
RUN mkdir -p /run /var/lib/apache2 /var/lib/php
RUN chmod -R 777 /run /var/lib/apache2 /var/lib/php /etc/php/${PHP_VERSION}/apache2/php.ini

### Test Apache Configuration

RUN apache2ctl -t

### Cleanup

RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*

# Image Config

COPY . /var/www/
WORKDIR /var/www
