FROM centos:7

#RUN yum groupinstall -y "Development Tools" \

RUN yum -y update \
  && yum reinstall -y glibc-common \ 
  && yum install -y asciidoc \
  bash-completion \
  git \
  less \
  man-db \
  sudo \
  zlib \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /tmp/*

# RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

ENV LANG=en_US.UTF-8

#Add gitpod user
RUN useradd -l -u 33333 -G wheel -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%wheel\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%wheel ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME

# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
  
#Install Amazon Corretto Java 8  
RUN yum install -y https://d3pxv6yz143wms.cloudfront.net/8.212.04.2/java-1.8.0-amazon-corretto-devel-1.8.0_212.b04-2.x86_64.rpm
  
###  Gitpod user ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for GitPod: success"

### Python ###
ENV PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
  && { echo; \
    echo 'eval "$(pyenv init -)"'; \
    echo 'eval "$(pyenv virtualenv-init -)"'; } >> .bashrc \
  && pyenv install 3.6.6 \
  && pyenv global 3.6.6 \
  && pip install virtualenv pipenv python-language-server[all]==0.19.0 \
  && rm -rf /tmp/*
  
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
    && { [ -z "$notOwnedFile" ] \
        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }  
 
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]
