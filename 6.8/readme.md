## CentOS 6.8 Base Minimal Install - 238 MB - Updated 11/28/2016 (tags: latest, 6)

***This container is built from centos:6.8, (397 MB Before Flatification)***

># Installation Steps:

### Install official CentOS 6 GPG Key

```bash
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```

### Install the Epel Repository

```bash
yum install -y epel-release
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
```

### Install the Remi Repository

```bash
cd /etc/yum.repos.d/;
curl -O http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
rpm -Uvh remi-release-6*.rpm;
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
rm -fr *.rpm
```

### Modify Remi Repo to enable remi base and PHP 5.5

```bash
sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo;
sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
```

### Update the OS and install required packages

```bash
yum clean all;
yum -y update;
yum -y install vim ansible;
yum clean all;
yum -fr /var/cache/*
```

### Install and Configure Ansible
```bash
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && \
python /tmp/get-pip.py && \
pip install pip --upgrade && \
rm -fr /tmp/get-pip.py && \
mkdir -p /etc/ansible/roles || exit 0 && \
echo localhost ansible_connection=local > /etc/ansible/hosts
```

### Cleanup

***Remove the contents of /var/cache/ after a yum update or yum install will save about 150MB from the image size***

```bash
yum clean all
rm -f /etc/yum.repos.d/*.rpm; rm -fr /var/cache/*
```

### Cleanup Locales

```bash
for x in `ls /usr/share/locale | grep -v -i en | grep -v -i local`;do rm -fr /usr/share/locale/$x; done && \
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done && \
rm -fr /usr/share/locale/ca* /usr/share/locale/den /usr/share/locale/men /usr/share/locale/wen /usr/share/locale/zen
```

```bash
cd /usr/lib/locale;
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive;
mv -f locale-archive locale-archive.tmpl;
build-locale-archive
```

### Set the default Timezone to EST

```bash
cp /etc/localtime /root/old.timezone && \
rm -f /etc/localtime && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
```

### Remove Man Pages and Docs to preserve Space

```bash
rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/*;
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*
```

### Set the Terminal CLI Prompt
***Copy the included Terminal CLI Color Scheme file to /etc/profile.d so that the terminal color will be included in all child images***

```bash
#!/bin/bash
if [ "$PS1" ]; then
    set_prompt () {
    Last_Command=$?
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    YellowBack='\[\e[01;43m\]'
    Green='\[\e[01;32m\]'
    Yellow='\[\e[01;33m\]'
    Black='\[\e[01;30m\]'
    Reset='\[\e[00m\]'
    FancyX=':('
    Checkmark=':)'

    # If it was successful, print a green check mark. Otherwise, print a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1="$Green$Checkmark "
    else
        PS1="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Black $YellowBack $TERMTAG $Reset $Red \\u@\\h"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
    fi
    # Print the working directory and prompt marker in blue, and reset the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
fi
```

### Prevent the .bashrc from being executed via SSH or SCP sessions

```bash
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc
```

### Set Dockerfile Runtime command
***Default command to run when lauched via docker run***

```bash
CMD /bin/bash
```
&nbsp;

># Building the image from the Dockerfile:

```bash
docker build -t build/centos .
```
&nbsp;

># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported.

&nbsp;

># Flatten the Image

***Run the build container***

```bash
docker run -it -d \
--name centos \
build/centos \
/bin/bash
```

***The run statement should start a detached container, however if you are attached, detach from the container***  
`CTL P` + `CTL Q`


***Export and Re-import the Container***
__Note that because we started the build container with the name of centos, we will use that in the export statement instead of the container ID.__

```bash
docker export centos | docker import - appcontainers/centos:latest
```

***Verify***

Issuing a `docker images` should now show a newly saved appcontainers/centos image, which can be pushed to the docker hub.

***Run the container***

```bash
docker run -it -d appcontainers/centos
```

&nbsp;

># Dockerfile Change-log:

    11/28/2016 - Update to OS, add vim, and ansible as it will replace runconfig scripts
    06/11/2016 - Update to 6.8
    12/14/2015 - Update to 6.7 official, epel change.
    09/29/2015 - Add Line to .bashrc to prevent additions to the basrc to be run from SSH/SCP login
    08/07/2015 - Upgrade to CentOS 6.7
    07/07/2015 - Squueze more space.. reduced from 270MB to 137MB
    05/06/2015 - Updated configuration scripts, pre import GPG repo keys
    04/27/2015 - Removed Locales other than English to conserve over 100MB
    04/06/2015 - Changed Postgres Repo from postgresql9.3 postgresql-9.4
