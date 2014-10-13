FROM java:7

# setup useful environment variables
ENV CONF_HOME     /usr/local/atlassian/confluence-data
ENV CONF_INST     /usr/local/atlassian/confluence
ENV CONF_VERSION  5.6.3

# install ``Atlassian Confluence``
RUN set -x \
    && mkdir -p             "${CONF_HOME}" \
    && chown nobody:nogroup "${CONF_HOME}" \
    && mkdir -p             "${CONF_INST}" \
    && curl -OLs            "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" \
    && tar -xzf             "atlassian-confluence-${CONF_VERSION}.tar.gz" --directory "${CONF_INST}/" --strip-components=1 \
    && rm                   "atlassian-confluence-${CONF_VERSION}.tar.gz" \
    && chmod -R 777         "${CONF_INST}/temp" \
    && chmod -R 777         "${CONF_INST}/logs" \
    && chmod -R 777         "${CONF_INST}/work" \
    && echo -e              "\nconfluence.home=$CONF_HOME" >> "${CONF_INST}/confluence/WEB-INF/classes/confluence-init.properties"

# run ``Atlassian Confluence`` as unprivileged user by default
USER nobody:nogroup

# expose default ``Atlassian Confluence`` HTTP port
EXPOSE 8090

# set volume mount points for installation and home directory
VOLUME ["/usr/local/atlassian/confluence-data", "/usr/local/atlassian/confluence"]

# run ``Atlassian Confluence`` as a foreground process by default
ENTRYPOINT ["/usr/local/atlassian/confluence/bin/start-confluence.sh"]
CMD ["-fg"]
