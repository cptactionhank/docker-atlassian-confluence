# Atlassian Confluence in a Docker container

[![Build Status](https://img.shields.io/circleci/project/cptactionhank/docker-atlassian-confluence.svg)](https://circleci.com/gh/cptactionhank/docker-atlassian-confluence)
[![Open Issues](https://img.shields.io/github/issues/cptactionhank/docker-atlassian-confluence.svg)](https://github.com/cptactionhank/docker-atlassian-confluence)
[![Stars on GitHub](https://img.shields.io/github/stars/cptactionhank/docker-atlassian-confluence.svg)](https://github.com/cptactionhank/docker-atlassian-confluence)
[![Forks on GitHub](https://img.shields.io/github/forks/cptactionhank/docker-atlassian-confluence.svg)](https://github.com/cptactionhank/docker-atlassian-confluence)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/cptactionhank/atlassian-confluence.svg)](https://registry.hub.docker.com/u/cptactionhank/atlassian-confluence)
[![Pulls on Docker Hub](https://img.shields.io/docker/pulls/cptactionhank/atlassian-confluence.svg)](https://registry.hub.docker.com/u/cptactionhank/atlassian-confluence)

A containerized installation of Atlassian Confluence setup with a goal of keeping the installation as default as possible, but with a few Docker related twists.

Want to help out, check out the contribution section.

## Important changes

The Confluence home and installation directory has been moved to `/var/atlassian/confluence` and `/opt/atlassian/confluence/` respectively.

The installation directory `/opt/atlassian/confluence` is not mounted as a volume as standard anymore. Should you need to persist changes in this directory run the container with the additional argument `--volume /opt/atlassian/confluence`.

## I'm in the fast lane! Get me started

To quickly get started with running an Confluence instance, first run the following command:
```bash
docker run --detach --publish 8090:8090 cptactionhank/atlassian-confluence:latest
```

Then use your browser to nagivate to `http://[dockerhost]:8090` and finish the configuration.

## The slower road to get started

An assumption is made that the docker version is at least 1.3.0 for the additional methods `docker exec` and `docker create`.

This is how to create the container for running an Atlassian Confluence instance and before you run the command as is take note of the `[your settings]` which should be left out or filled to suit your needs.

```bash
docker create [your settings] cptactionhank/atlassian-confluence:latest
```

Below is some documentation for additional configuration of the Confluence application, keep in mind this is the only tested configuration to suit own needs.

### Additional Confluence settings

Use the `CATALINA_OPTS` environment variable for changing advanced settings eg. changing memory consumption or extending plugin loading timeout. All possible configuration settings can be found at the Atlassian Confluence [documentation]().

Use with Docker add `--env 'CATALINA_OPTS=[settings]'` as part of your container configuration flags.

#### JVM memory configuration

To change the default memory configuration to your machine with extended memory usage settings add the following string to your `CATALINA_OPTS` environment variable. This will setup the JVM to be running with 128MB as minimum and 1GB as maximum allocatable memory.

```
-Xms128m -Xmx1024m
```

More information about [`-Xms`](http://docs.oracle.com/cd/E13150_01/jrockit_jvm/jrockit/jrdocs/refman/optionX.html#wp999528) and [`-Xmx`](http://docs.oracle.com/cd/E13150_01/jrockit_jvm/jrockit/jrdocs/refman/optionX.html#wp999527) visit [here](http://docs.oracle.com/cd/E13150_01/jrockit_jvm/jrockit/jrdocs/refman/optionX.html).

#### Plugin loading timeout

To change the plugin loading timeout to _5 minutes_ the following string should be added to the `CATALINA_OPTS` environment variable.

```
-Datlassian.plugins.enable.wait=300
```

#### Apache Portable Runtime (APR) based Native library for Tomcat

This is enabled by default.

### Running as a different user

Here will be information on how to run as a different user

```
--user "docker-user:docker-group"
```

make sure the home directory `/var/local/atlassian/confluence` is set up with full read, write, and execute permissions on the directory.

If not mounting the home directory volume yourself you can change the folder permissions by

```bash
$ docker exec [container] chown docker-user:docker-group /var/local/atlassian/confluence
```

Please note that the exec will be executed as the supplied user in the `docker create` command, ie. `docker-user:docker-group`. You can circumvent this by

```bash
$ docker run -ti --rm --user root:root --volumes-from [container] java:7 chown docker-user:docker-group /var/local/atlassian/confluence
```

### Customizations

Example mounting files to change log4j logging output:

```
--volume "[hostpath]/log4j.properties:/opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties"
```

or by:

```bash
$ docker run -ti --rm --user root:root --volumes-from [container] java:7 vi /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties
```

This should also be modifiable to suit your needs.

### Reverse Proxy Support

You need to change the `/opt/atlassian/confluence/conf/server.xml` file inside the container to include a couple of Connector [attributes](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Proxy_Support).

Gaining access to the `server.xml` file on a running container use the following docker command edited to suit your setup

```bash
$ docker exec <container> vi /opt/atlassian/confluence/conf/server.xml
```

Within this container the file can be accessed and edited to match your configuration (remember to restart the Confluence container after). I recommend installing the Nano text editor unless you have the required knowledge to use vi.

#### HTTP

For a reverse proxy server listening on port 80 (HTTP) for inbound connections add and edit the following connector attributes to suit your setup.

```xml
<connector ...
   proxyName="example.com"
   proxyPort="80"
   scheme="http"
   ...
></connector>
```

#### HTTPS

For a reverse proxy server listening on port 443 (HTTPS) for inbound connections add and edit the following connector attributes to suit your setup.

```xml
<connector ...
   proxyName="example.com"
   proxyPort="443"
   scheme="https"
   ...
></connector>
```

## Contributions

This has been made with the best intentions and current knowledge so it shouldn't be expected to be flawless. However you can support this too with best practices and other additions. Travis-CI has been setup to build the Dockerfile and run acceptance tests on the application image to ensure it is tested and working.

Out of date documentation, version, lack of tests, etc. why not help out by either creating an issue and open a discussion or sending a pull request with modifications.

Acceptance tests are performed by Circle-CI in Ruby using the RSpec framework.
