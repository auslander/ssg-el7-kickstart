FROM centos:7

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* \
  && yum -y update \
  && yum -y install epel-release \
  && yum -y update \
  && yum search php
