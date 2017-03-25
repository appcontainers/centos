###########################################################
# Dockerfile to build the CentOS 6.8 Base Container
# Based on: library/centos:6.8
# DATE: 11/25/16
# COPYRIGHT: Appcontainers.com
###########################################################

# Set the base image in namespace/repo format. 
# To use repos that are not on the docker hub use the example.com/namespace/repo format.
FROM library/centos:6.8

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

###########################################################
#*********************  APP VERSIONS  *********************
###########################################################


###########################################################
#***********  OVERRIDE ENABLED ENV VARIABLES  *************
###########################################################

ENV TERMTAG CentOS6Base

###########################################################
#**************  ADD REQUIRED APP FILES  ******************
###########################################################

# Import keys and fix passwd issue.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

###########################################################
#***************  UPDATES & PRE-REQS  *********************
###########################################################

# Clean, Update, and Install... then clear non English local data.
RUN yum clean all && \

# Install required packages
yum -y install epel-release && \
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 && \

# Download and install the Remi repository
cd /etc/yum.repos.d/ && \
curl -O http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
rpm -Uvh remi-release-6*.rpm && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi && \
rm -fr *.rpm && \

#Enable the remi repo
sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo && \
sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo && \

# Now that epel is installed, clean all again and update
yum clean all && \
yum -y update && \

# Remove yum cache this bad boy can be 150MBish
yum clean all && \
rm -fr /var/cache/*

###########################################################
#***************  APPLICATION INSTALL  ********************
###########################################################


###########################################################
#**************  POST DEPLOY CLEAN UP  ********************
###########################################################

# Remove locales other than english
RUN for x in `ls /usr/share/locale | grep -v -i en | grep -v -i local`;do rm -fr /usr/share/locale/$x; done && \
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done && \
rm -fr /usr/share/locale/ca* /usr/share/locale/den /usr/share/locale/men /usr/share/locale/wen /usr/share/locale/zen && \
cd /usr/lib/locale && \
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive && \
mv -f locale-archive locale-archive.tmpl && \
build-locale-archive

# Set the default Timezone to EST
RUN cp /etc/localtime /root/old.timezone && \
rm -f /etc/localtime && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Remove documentation to cut down the image size
RUN rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* && \
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*

# Rebuild the RPM Database
RUN rm -f /var/lib/rpm/__db* && \
rpm --rebuilddb

###########################################################
#*************  CONFIGURE START ITEMS  ********************
###########################################################

ADD termcolor.sh /etc/profile.d/PS1.sh
RUN chmod +x /etc/profile.d/PS1.sh

# Add the following to prevent any additions to the .bashrc from being executed via SSH or SCP sessions
RUN echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc

CMD /bin/bash

###########################################################
#************  EXPOSE APPLICATION PORTS  ******************
###########################################################


###########################################################
#***************  OPTIONAL / LEGACY  **********************
###########################################################

# Install Postgres 9.4 Repository
# rpm -ivh http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm && \

# Automatically Disable SELinux
# RUN sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# --> 9/29/2015 Commenting out to see if it fixes the tail issue.
# This can be undone by reinstalling the hwdata package from yum..
# rm -fr /usr/share/hwdata/* && \

# This can be undone by reinstalling shared-mime-info
# rm -fr /usr/share/mime/application/* /usr/share/mime/packages/* && \

# Remove Non America TimeZone Data
# This can be undone via: wget 'ftp://elsie.nci.nih.gov/pub/tzdata*.tar.gz'
# for x in `ls /usr/share/zoneinfo|grep -v America`; do rm -fr /usr/share/zoneinfo/$x;done;
