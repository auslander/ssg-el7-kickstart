FROM centos:7

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* \
  && yum -y update \
  && yum -y install epel-release \
  && yum -y update \
  && yum -y install php \ 
    php-all-dev \
    php-ctype \
    php-curl \
    php-date \
    php-gd \
    php-gettext \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-net-ftp \
    php-pgsql \
    php-sqlite3 \
    php-tokenizer \
    php-xml \
    php-zip \
  && yum -y clean all 
  
