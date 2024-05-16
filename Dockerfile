################################################################################
# Dockerfile de construcao do container APP com os pacotes basicos
################################################################################

FROM almalinux:9

LABEL \
    org.opencontainers.image.title="Imagem docker para SEI 5 em php"
 
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm; \
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm; \
    dnf module install -y php:remi-8.2

RUN dnf --enablerepo=crb install -y aspell
RUN dnf install -y \
      php-mbstring \
      php-bcmath \
      php-bz2 \
      php-calendar \
      php-ctype \
      php-curl \
      php-dom \
      php-exif \
      php-fileinfo \
      php-gd \
      php-gettext \
      php-gmp \
      php-iconv \
      php-imap \
      php-intl \
      php-ldap \
      php-mbstring \
      php-mysqli \
      php-odbc \
      php-openssl \
      php-pcntl \
      php-pdo \
      php-pear \
      php-pecl-apcu \
      php-pecl-igbinary \
      php-pecl-mcrypt \
      php-pecl-memcache \
      php-pecl-xdebug \
      php-pgsql \
      php-phar \
      php-pspell \
      php-simplexml \
      php-sodium \
      php-shmop \
      php-snmp \
      php-soap \
      php-xml \
      php-zip \
      php-zlib \
      php-pecl-uploadprogress; \ 
      dnf install -y \ 
         httpd \
         xorg-x11-fonts-75dpi \
         xorg-x11-fonts-Type1 \ 
         libpng \ 
         libjpeg \
         openssl \
         icu \
         libX11 \
         libXext \
         libXrender; \
       dnf install -y wget ; \
       wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm ; \
       dnf install -y ./wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm; \
       rm -f ./wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm; \
       dnf install -y glibc-locale-source; \
       dnf install -y java-1.8.0-openjdk; \
       dnf clean all;
 
COPY assets/sei.ini /etc/php.d/99_sei.ini
COPY assets/sei.ini /etc/php-fpm.d/99_sei.ini
COPY assets/xdebug.ini /etc/php.d/99_xdebug.ini
COPY assets/sei.conf /etc/httpd/conf.d/

# Pasta para arquivos externos
RUN mkdir -p /var/sei/arquivos && chown -R apache.apache /var/sei/arquivos && chmod 777 /tmp

RUN mkdir -p /var/log/sei && mkdir -p /var/log/sip
RUN sed -e 's/127.0.0.1:9000/9000/' \
        -e '/allowed_clients/d' \
        -e '/catch_workers_output/s/^;//' \
        -e '/error_log/d' \
        -e 's/;clear_env = no/clear_env = no/' \
        -i /etc/php-fpm.d/www.conf
        
RUN mkdir -p /run/php-fpm
RUN localedef pt_BR -i pt_BR -f ISO-8859-1 ; \
    localedef pt_BR.ISO-8859-1 -i pt_BR -f ISO-8859-1 ; \
    localedef pt_BR.ISO8859-1 -i pt_BR -f ISO-8859-1

ADD assets/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000
CMD ["bash", "-c", "php-fpm && httpd -DFOREGROUND"]
