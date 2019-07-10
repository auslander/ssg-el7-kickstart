FROM centos:7

RUN yum -y update \
  && yum reinstall -y glibc-common \ 
  && yum install -y asciidoc \
    bash-completion \
    bzip2 bzip2-devel \
    findutils \
    gcc \
    glibc \
    gd gd-devel \
    git \
    less \
    libffi-devel \
    make \
    man-db \
    openssl openssl-devel \
    readline-devel \
    sqlite sqlite-devel \
    sudo \
    xz xz-devel \
    zlib zlib-devel \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /tmp/*

# RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

ENV LANG=en_US.UTF-8

# Add gitpod user
RUN useradd -l -u 33333 -G wheel -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%wheel\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%wheel ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME

# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Apache and Nginx ###
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* \
  && yum -y update \
  && yum -y install epel-release \
  && yum -y install http \
    nginx \
    nginx-extras \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /tmp/* \
  && mkdir /var/run/httpd \
  && mkdir /var/lock/httpd \
  && mkdir /var/run/nginx \
  && chown -R gitpod:gitpod /etc/httpd /var/run/httpd /var/lock/httpd /var/log/httpd \
  && chown -R gitpod:gitpod /etc/nginx /var/run/nginx /var/lib/nginx/ /var/log/nginx/
  
### PHP ###
RUN yum -y update \
  && yum -y install php-cli \
    php-zip \
    wget \
    unzip \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && yum -y install php \ 
    php-ctype \
    php-curl \
    php-date \
    php-gd \
    php-gettext \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-pgsql \
    php-sqlite3 \
    php-tokenizer \
    php-xml \
    php-zip \
  && yum -y clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /tmp/*

# Change ownership of .pki folder in home directory to gitpod
RUN chown -R gitpod:gitpod /home/gitpod/.pki

###  Gitpod user ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for GitPod: success"

### Java Maven Gradle ###
RUN curl -s "https://get.sdkman.io" | bash \
  && bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh \
  && sdk install java 8.0.212-amzn \
  && sdk install gradle \
  && sdk install maven \
  && mkdir /home/gitpod/.m2 \
  && printf '<settings>\n  <localRepository>/workspace/m2-repository/</localRepository>\n</settings>\n' > /home/gitpod/.m2/settings.xml"
ENV GRADLE_USER_HOME=/workspace/.gradle/

### Python ###
ENV PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash  \
  && { echo; \
    echo 'eval "$(pyenv init -)"'; \
    echo 'eval "$(pyenv virtualenv-init -)"'; } >> .bashrc \
  && pyenv install 2.7.15 \
  && pyenv install 3.7.2 \
  && pyenv global 2.7.15 3.7.2 \
  && pip2 install --upgrade pip \
  && pip2 install virtualenv pipenv pylint rope flake8 autopep8 pep8 pylama pydocstyle bandit python-language-server[all]==0.25.0 \
  && pip3 install --upgrade pip \
  && pip3 install virtualenv pipenv pylint rope flake8 autopep8 pep8 pylama pydocstyle bandit python-language-server[all]==0.25.0 \
  && rm -rf /tmp/*

RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
    && { [ -z "$notOwnedFile" ] \
        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }  
 
# RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
# systemd-tmpfiles-setup.service ] || rm -f $i; done); \
# rm -f /lib/systemd/system/multi-user.target.wants/*;\
# rm -f /etc/systemd/system/*.wants/*;\
# rm -f /lib/systemd/system/local-fs.target.wants/*; \
# rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
# rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
# rm -f /lib/systemd/system/basic.target.wants/*;\
# rm -f /lib/systemd/system/anaconda.target.wants/*;
# VOLUME [ "/sys/fs/cgroup" ]

###  root user ###
User root

# CMD ["/usr/sbin/init"]
