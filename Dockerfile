FROM ubuntu:trusty

# add ``Oracle Java JRE`` to repository (what's weird is that this key presents as ``Launchpad VLC``)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/launchpad-webupd8team-java.list \
    && echo debconf shared/accepted-oracle-license-v1-1 select true \
       | sudo debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true \
       | sudo debconf-set-selections

# install ``Wget``, ``Apache Portable Runtime`` and ``Java 7 JRE`` which is supported by ``Atlassian Jira``
RUN apt-get update -qq \
    && apt-get install -qqy wget libtcnative-1 oracle-java7-installer

# setup primary environment variables
ENV JAVA_HOME     /usr/lib/jvm/java-7-oracle
ENV CONF_HOME     /home/confluence
# setup secondary environment helper variables
ENV CONFLUENCE_VERSION  5.5.6

# create non-root user to run ``Atlassian Confluence``
RUN useradd --create-home --comment "Account for running Atlassian Confluence" confluence \
    && chmod -R a+rw ~confluence

# download ``Atlassian Confluence`` standalone archive version
RUN wget                    "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" \
    && tar -xzf             "atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" \
    && rm                   "atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" \
    && mkdir -p             "/usr/local/atlassian" \
    && mv                   "atlassian-confluence-${CONFLUENCE_VERSION}" "/usr/local/atlassian/confluence" \
    && echo -e              "\nconfluence.home=$CONF_HOME" >> "/usr/local/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties" \
    && chown -R confluence: "/usr/local/atlassian/confluence/temp" \
    && chown -R confluence: "/usr/local/atlassian/confluence/logs" \
    && chown -R confluence: "/usr/local/atlassian/confluence/work" \
    && chmod -R 777         "/usr/local/atlassian/confluence/temp" \
    && chmod -R 777         "/usr/local/atlassian/confluence/logs" \
    && chmod -R 777         "/usr/local/atlassian/confluence/work"

# set the principal user as new non-root confluence account
USER confluence

# expose default ``Atlassian Confluence`` HTTP port
EXPOSE 8090

# set volume mount points for installation and home directory
VOLUME ["/home/confluence", "/usr/local/atlassian/confluence"]

# run ``Atlassian Confluence`` and as a foreground process by default
ENTRYPOINT ["/usr/local/atlassian/confluence/bin/start-confluence.sh"]
CMD ["-fg"]
