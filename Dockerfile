FROM ubuntu

WORKDIR /webapps/grassroots
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#rethinkDB
RUN /bin/bash -c "source /etc/lsb-release" && echo "deb http://download.rethinkdb.com/apt trusty main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list && \
    wget -qO- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add - && \
    sudo apt-get update && \
    sudo apt-get -y install rethinkdb


#Node
RUN sudo apt-get update && \
    sudo apt-get -y install nodejs && \
    sudo apt-get -y install npm
RUN /bin/bash -c "ln -s /usr/bin/nodejs /usr/local/bin/node"

#Express
RUN npm install express -g

#NEAR
WORKDIR /opt/NEAR-Stack
RUN git clone https://github.com/shadowsyntax/NEAR-Stack.git 
#    npm cache clean && \
#    npm install && \
#    npm install -g gulp && \
#    npm install -g bower && \
#    bower --allow-root install && \
#    npm install

#Add runit services
WORKDIR /webapps/grassroots
ADD sv /etc/service 

#Start NEAR-Stack server
WORKDIR /opt/NEAR-Stack
RUN /bin/bash -c "cd /opt/NEAR-Stack" && gulp
