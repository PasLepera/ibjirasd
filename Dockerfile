FROM paslepera/iborajre8:0.1
LABEL maintainer="Pasquale Lepera <pasquale@ibuildings.it>"

ENV JIRA_SD_VERSION 3.13.0
ENV JIRA_HOME     	/var/atlassian/application-data/jirasd
ENV JIRA_INSTALL  	/opt/atlassian/jirasd
ENV JIRA_USER	  	jira
ENV JIRA_INSTALLER	atlassian-servicedesk-$JIRA_SD_VERSION-x64.bin

COPY ./installresp /tmp/installresp
COPY ./entrypoint.sh /entrypoint.sh

RUN deps=" \
	libtcnative-1 xmlstarlet \
	curl \
	wget \
	ca-certificates \
	openssl \
        " \
	set -x && \
        export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y $deps --no-install-recommends && \
	\
	useradd --create-home --shell /bin/bash $JIRA_USER && \
	\
	cd /tmp && \
        wget --no-check-certificate https://product-downloads.atlassian.com/software/jira/downloads/$JIRA_INSTALLER && \
        chmod a+x $JIRA_INSTALLER && \
        ./$JIRA_INSTALLER < ./installresp && \ 
        mkdir -p $JIRA_HOME && \
	\
	chown -R $JIRA_USER:$JIRA_USER $JIRA_HOME && \
	chown -R $JIRA_USER:$JIRA_USER $JIRA_INSTALL && \
	\
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${JIRA_HOME}"]

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/atlassian/jirasd/bin/start-jira.sh", "-fg"]
