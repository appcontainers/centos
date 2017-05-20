# This build script will create the docker images for the CentOS 6/7 Linux Base Images
# 2 Images will be created for each version, one bare, and the other including Ansible

# CD into the Main Project directory before launching this script

# CentOS 6 Base Container Image
cd 6/base
docker build -t build/centos .
docker run -it -d --name centos build/centos /bin/bash
docker export centos | docker import - appcontainers/centos:latest
docker tag "appcontainers/centos:latest" "appcontainers/centos:6"
docker kill centos; docker rm centos
docker push "appcontainers/centos:latest"
docker push "appcontainers/centos:6"
docker images
docker rmi build/centos
docker rmi "appcontainers/centos:6"
docker rmi "appcontainers/centos:latest"

# CentOS 6 Base Container Image with Ansible
cd ../ansible
docker build -t build/centos .
docker run -it -d --name centos build/centos /bin/bash
docker export centos | docker import - appcontainers/centos:ansible
docker tag "appcontainers/centos:ansible" "appcontainers/centos:ansible-6"
docker kill centos; docker rm centos
docker push "appcontainers/centos:ansible"
docker push "appcontainers/centos:ansible-6"
docker images
docker rmi build/centos
docker rmi "appcontainers/centos:ansible-6"
docker rmi "appcontainers/centos:ansible"
docker rmi "centos:6.9"

# CentOS 7 Base Container Image
cd ../../7/base
docker build -t build/centos .
docker run -it -d --name centos build/centos /bin/bash
docker export centos | docker import - appcontainers/centos:7
docker kill centos; docker rm centos
docker push "appcontainers/centos:7"
docker images
docker rmi build/centos
docker rmi "appcontainers/centos:7"

# CentOS 6 Base Container Image with Ansible
cd ../ansible
docker build -t build/centos .
docker run -it -d --name centos build/centos /bin/bash
docker export centos | docker import - appcontainers/centos:ansible-7
docker kill centos; docker rm centos
docker push "appcontainers/centos:ansible-7"
docker images
docker rmi build/centos
docker rmi "appcontainers/centos:ansible-7"
docker rmi "centos:7"