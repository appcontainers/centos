############################################################
# Dockerfile to build the CentOS 6.6 Base Container
# Based on: centos:6.6
# DATE: 07/06/15
# COPYRIGHT: Appcontainers.com
############################################################

# Set the base image in namespace/repo format. 
# To use repos that are not on the docker hub use the example.com/namespace/repo format.
FROM library/centos:6.6

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

#####################################################################################################################
#**************************************************  APP VERSIONS  **************************************************
#####################################################################################################################


#####################################################################################################################
#******************************************  OVERRIDE ENABLED ENV VARIABLES  ****************************************
#####################################################################################################################

ENV TERMTAG CENTOS6

#####################################################################################################################
#********************************************  ADD REQUIRED APP FILES  **********************************************
#####################################################################################################################

# Import keys and fix passwd issue.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Download and install Epel, and Remi repositories.
cd /etc/yum.repos.d/ && \
curl -O http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
curl -O http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi && \
rm -fr *.rpm

#Enable the remi repo
RUN sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo && \
sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo

#####################################################################################################################
#**********************************************  UPDATES & PRE-REQS  ************************************************
#####################################################################################################################

# Clean, Update, and Install... then clear non English local data.
RUN yum clean all && \
yum -y update && \

# Install required packages
# yum -y install <PKGLIST> && \

# Remove yum cache this bad boy can be 150MBish
rm -fr /var/cache/*

# Remove locales other than english
RUN for x in `ls /usr/share/locale | grep -v -i en | grep -v -i local`;do rm -fr /usr/share/locale/$x; done && \
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done && \
rm -fr /usr/share/locale/ca* /usr/share/locale/den /usr/share/locale/men /usr/share/locale/wen /usr/share/locale/zen && \
cd /usr/lib/locale && \
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive && \
mv -f locale-archive locale-archive.tmpl && \
build-locale-archive


#####################################################################################################################
#**********************************************  APPLICATION INSTALL  ***********************************************
#####################################################################################################################


#####################################################################################################################
#*********************************************  POST DEPLOY CLEAN UP  ***********************************************
#####################################################################################################################

# Remove random un-necessary crap
RUN rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* && \
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* && \

# This can be undone by reinstalling the hwdata package from yum..
rm -fr /usr/share/hwdata/* && \

# This can be undone by reinstalling shared-mime-info
rm -fr /usr/share/mime/application/* /usr/share/mime/packages/*

# Rebuild the RPM Database
RUN rm -f /var/lib/rpm/__db* && \
rpm --rebuilddb

#####################################################################################################################
#*********************************************  CONFIGURE START ITEMS  **********************************************
#####################################################################################################################

ADD termcolor.sh /etc/profile.d/PS1.sh
RUN chmod +x /etc/profile.d/PS1.sh

CMD /bin/bash

#####################################################################################################################
#********************************************  EXPOSE APPLICATION PORTS  ********************************************
#####################################################################################################################


#####################################################################################################################
#***********************************************  OPTIONAL / LEGACY  ************************************************
#####################################################################################################################

# Install Postgres 9.4 Repository
# rpm -ivh http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm && \

# Automatically Disable SELinux
# RUN sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux