**CentOS 6.7 Base Minimal Install - 144 MB - Updated 9/29/2015**
-->  appcontainers/centos:6

**CentOS 7 Base Minimal Install - 152 MB - Updated 7/7/2015**
-->  appcontainers/centos:7

# CentOS 6.7 Base Minimal Install - 144 MB - Updated 9/29/2015 (tag:latest,6.7)

***This container is built from centos:6.7, (463 MB Before Flatification)***


># Installation Steps:

##Install required packages##

   `rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6`

##Install the Epel, Remi, and Postgres 9.4 Repositories.##

    cd /etc/yum.repos.d/;
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm;
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
    rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi

##Modify Remi Repo to enable remi base and PHP 5.5##

    sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
    sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo

##Update the OS##

   `yum -y update`

##Cleanup (removing the contents of /var/cache/ after a yum update or yum install will save about 150MB from the image##

   `rm -f /etc/yum.repos.d/*.rpm; rm -fr /var/cache/*`

##Cleanup Locales##

    for x in `ls /usr/share/locale | grep -v -i en | grep -v -i local`;do rm -fr /usr/share/locale/$x; done && \
    for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done && \
    rm -fr /usr/share/locale/ca* /usr/share/locale/den /usr/share/locale/men /usr/share/locale/wen /usr/share/locale/zen && \

    cd /usr/lib/locale
    localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive
    mv -f locale-archive locale-archive.tmpl
    build-locale-archive

##Set the default Timezone to EST##
    
    cp /etc/localtime /root/old.timezone && \
    rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

##Remove Man Pages and Docs to preserve Space##

    rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/*
    rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*

##Remove a few other misc items##

    # This can be undone by reinstalling the hwdata package via yum..
    # rm -fr /usr/share/hwdata/* && \

    # This can be undone by reinstalling shared-mime-info via yum
    # rm -fr /usr/share/mime/application/* /usr/share/mime/packages/*

    # This can be undone via: wget 'ftp://elsie.nci.nih.gov/pub/tzdata*.tar.gz'
    for x in `ls /usr/share/zoneinfo|grep -v America`; do rm -fr /usr/share/zoneinfo/$x;done;

##Copy the included Terminal CLI Color Scheme file to /etc/profile.d so that the terminal color will be included in all child images##

    if [ "$PS1" ]; then
    set_prompt () {
    Last_Command=$? # Must come first!
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    YellowBack='\[\e[01;43m\]'
    Green='\[\e[01;32m\]'
    Yellow='\[\e[01;33m\]'
    Black='\[\e[01;30m\]'
    Reset='\[\e[00m\]'
    FancyX='\342\234\227'
    Checkmark='\342\234\223'

    # Add a bright white exit status for the last command
    #PS1="$White\$? "
    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1="$Green$Checkmark "
    else
        PS1="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user
    # and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Black $YellowBack $TERMTAG $Reset $Red \\u@\\h"
        #PS1+="$Red\\u@\\h $YellowBack DEV $Reset"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
        #PS1+="$Green\\u@\\h $YellowBack DEV $Reset"
    fi
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
    fi

##Add the following to prevent any additions to the .bashrc from being executed via SSH or SCP sessions
    echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
    echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc

##Set Dockerfile Runtime command (default command to run when lauched via docker run)##
    
    CMD /bin/bash    


># Building the image from the Dockerfile:
    
   `docker build -t build/centos .`

># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported. 

##Flatten##

>###### Run the build container

    docker run -it \
    --name centosbuild \
    -h centosbuild  \
    build/centos \
    /bin/bash
 
   
###### The above will bring you into a running shell, So Detach from the container
    
   `CTL P` + `CTL Q`


###### Export and Reimport the Container note that because we started the build container with the name of centosbuild, we will use that in the export statement instead of the container ID.

    
    docker export centosbuild | docker import - appcontainers/centos:latest

># Verify

Issuing a `docker images` should now show a newly saved appcontainers/centos image, which can be pushed to the docker hub.

># Running the container
    
   `docker run -it -d appcontainers/centos`

># Dockerfile Changelog

    09/29/2015 - Add Line to .bashrc to prevent additions to the basrc to be run from SSH/SCP login

    08/07/2015 - Upgrade to CentOS 6.7

    07/07/2015 - Squueze more space.. reduced from 270MB to 137MB
    
    05/06/2015 - Updated configuration scripts, pre import GPG repo keys
    
    04/27/15 - Removed Locales other than English to conserve over 100MB
    
    04/06/15 - Changed Postgres Repo from postgresql9.3 postgresql-9.4
