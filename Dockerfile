FROM java:7

# setup useful environment variables
ENV CONF_HOME     /var/local/atlassian/confluence
ENV CONF_INSTALL  /usr/local/atlassian/confluence
ENV CONF_VERSION  5.6.3

# install ``Atlassian Confluence``
RUN set -x \
    && apt-get install -qqy libtcnative-1 \
    && mkdir -p             "${CONF_HOME}" \
    && chown nobody:nogroup "${CONF_HOME}" \
    && mkdir -p             "${CONF_INSTALL}" \
    && curl -Ls             "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}/" --strip-components=1 \
    && chmod -R 777         "${CONF_INSTALL}/temp" \
    && chmod -R 777         "${CONF_INSTALL}/logs" \
    && chmod -R 777         "${CONF_INSTALL}/work" \
    && mkdir                "${CONF_INSTALL}/conf/Catalina" \
    && chmod -R 777         "${CONF_INSTALL}/conf/Catalina" \
    && echo -e              "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties"

# run ``Atlassian Confluence`` as unprivileged user by default
USER nobody:nogroup

# expose default ``Atlassian Confluence`` HTTP port
EXPOSE 8090

# set volume mount points for installation and home directory
VOLUME ["/usr/local/atlassian/confluence", "/var/local/atlassian/confluence"]

# run ``Atlassian Confluence`` as a foreground process by default
ENTRYPOINT ["/usr/local/atlassian/confluence/bin/start-confluence.sh", "-fg"]
