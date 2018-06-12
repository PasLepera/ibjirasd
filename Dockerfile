FROM ubuntu:16.04

##
# Install Java Oracle 
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8
ENV LC_ALL      	C

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends locales; \
    locale-gen en_US.UTF-8; \
    apt-get dist-upgrade -y; \
    apt-get --purge remove openjdk*; \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections; \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        oracle-java8-installer \
        oracle-java8-set-default \
        libtcnative-1 \
        xmlstarlet \
        curl \
        wget \
        ca-certificates \
        openssl \
        sudo; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install dumb-init for entrypoint
ENV DUMBINIT_VERSION=1.2.0
ADD https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

RUN set -ex ; \
    export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get upgrade -y --no-install-recommends libtcnative-1 xmlstarlet curl wget ca-certificates openssl; \
	apt-get clean all; \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./response.varfile /tmp/response.varfile
COPY ./jira.sh /jira.sh

##
# Install Jira
ENV JIRA_SD_VERSION 3.13.0
ENV JIRA_HOME     	/var/atlassian/application-data/jira
ENV JIRA_INSTALL  	/opt/atlassian/jira
ENV JIRA_USER	  	jira
ENV JIRA_GROUP          jira
ENV JIRA_INSTALLER	atlassian-servicedesk-$JIRA_SD_VERSION-x64.bin

RUN set -ex; \
    cd /tmp; \
    wget --no-check-certificate https://www.atlassian.com/software/jira/downloads/binary/$JIRA_INSTALLER; \
    chmod a+x $JIRA_INSTALLER; \
    ./$JIRA_INSTALLER < /tmp/response.varfile; \ 
    mkdir -p $JIRA_HOME; \
    chown -R $JIRA_USER:$JIRA_GROUP $JIRA_HOME; \
    chown -R $JIRA_USER:$JIRA_GROUP $JIRA_INSTALL; \
    chown -R $JIRA_USER:$JIRA_GROUP /jira.sh; \
    chmod +x /jira.sh;


EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

CMD ["/jira.sh", "/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
