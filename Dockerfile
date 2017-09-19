FROM openjdk:8

# Setup useful environment variables
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  6.3.4

ENV JAVA_CACERTS  $JAVA_HOME/jre/lib/security/cacerts
ENV CERTIFICATE   $CONF_HOME/certificate

ENV CONF_DOWNLOAD_URL http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz

ENV MYSQL_VERSION 5.1.38
ENV MYSQL_DRIVER_DOWNLOAD_URL http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.tar.gz

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER            daemon
ENV RUN_GROUP           daemon

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                           "${CONF_HOME}" \
    && chmod -R 700                       "${CONF_HOME}" \
    && chown ${RUN_USER}:${RUN_GROUP}     "${CONF_HOME}" \
    && mkdir -p                           "${CONF_INSTALL}/conf" \
    && curl -Ls                           "${CONF_DOWNLOAD_URL}" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                           "${MYSQL_DRIVER_DOWNLOAD_URL}" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}-bin.jar" \
    && chmod -R 700                       "${CONF_INSTALL}/conf" \
    && chmod -R 700                       "${CONF_INSTALL}/temp" \
    && chmod -R 700                       "${CONF_INSTALL}/logs" \
    && chmod -R 700                       "${CONF_INSTALL}/work" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONF_INSTALL}/conf" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONF_INSTALL}/temp" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONF_INSTALL}/logs" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONF_INSTALL}/work" \
    && echo -e                            "\nconfluence.home=${CONF_HOME}" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && xmlstarlet                         ed --inplace \
        --delete                          "Server/@debug" \
        --delete                          "Server/Service/Connector/@debug" \
        --delete                          "Server/Service/Connector/@useURIValidationHack" \
        --delete                          "Server/Service/Connector/@minProcessors" \
        --delete                          "Server/Service/Connector/@maxProcessors" \
        --delete                          "Server/Service/Engine/@debug" \
        --delete                          "Server/Service/Engine/Host/@debug" \
        --delete                          "Server/Service/Engine/Host/Context/@debug" \
                                          "${CONF_INSTALL}/conf/server.xml" \
    && touch -d "@0"                      "${CONF_INSTALL}/conf/server.xml" \
    && chown ${RUN_USER}:${RUN_GROUP}     "${JAVA_CACERTS}"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER ${RUN_USER}:${RUN_GROUP}

# Expose default HTTP connector port.
EXPOSE 8090
EXPOSE 8091

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["${CONF_INSTALL}", "${CONF_HOME}/logs"]

# Set the default working directory as the Confluence home directory.
WORKDIR ${CONF_HOME}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/catalina.sh", "run"]
