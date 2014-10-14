FROM ubuntu

WORKDIR /webapps/grassroots
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

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
RUN source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list && \
    wget -qO- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add - && \
    sudo apt-get update && \
    sudo apt-get install rethinkdb


#Node
RUN curl http://nodejs.org/dist/v0.10.29/node-v0.10.29-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm

#Express
RUN npm install express -g

#NEAR
RUN git clone https://github.com/shadowsyntax/NEAR-Stack.git 
RUN cd NEAR-Stack && \
    npm install

RUN npm install -g gulp
RUN npm install -g bower

RUN cd NEAR-Stack && \
    bower --allow-root install && \
    npm install

#Add runit services
ADD sv /etc/service 
