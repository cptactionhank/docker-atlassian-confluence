# Atlassian Confluence in a Docker Container

Use the awesome magic of Docker to isolate and run Atlassian Confluence isolated and with ease.

## Getting started

To quickly get started with running an Confluence instance, first run the following command:

```bash
docker run -ti --rm -p 8090:8090 cptactionhank/atlassian-confluence:latest
```

Then use your browser to nagivate to `http://<yourserver>:8090` and finish the configuration.

## Advanced configuration

Below is some documentation for additional configuration of the Confluence application, keep in mind this is the only tested configuration to suit own needs.

### Additional Confluence settings

Use the `CATALINA_OPTS` environment variable for changing advanced settings eg.
is also used to enable _Apache Portable Runtime (APR) based Native library for
Tomcat_ or extending plugin loading timeout.

An example running the Atlassian Confluence container with extended memory usage settings of 128MB as minimum and a maximum of 1GB.

```bash
docker run ... --env "CATALINA_OPTS=-Xms128m -Xmx1024m" cptactionhank/atlassian-confluence
```

#### Plugin loading timeout

To change the plugin loading timeout to 5 minutes the following value should be added to the `CATALINA_OPTS` variable.

```
-Datlassian.plugins.enable.wait=300
```

#### Apache Portable Runtime (APR) based Native library for Tomcat

This should enable Tomcat superspeeds.

```
-Djava.library.path=/usr/lib/x86_64-linux-gnu:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
```

### Reverse Proxy Support

You need to change the `/usr/local/atlassian/confluence/conf/server.xml` file inside the container to include a couple of Connector [attributes](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Proxy_Support).

Gaining access to the `server.xml` file on a running container use the following docker command edited to suit your setup

```bash
docker run -ti --rm \
       --volumes-from <confluence-container-name> \
       ubuntu:latest
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

## Help, Complaints, and Additions
Create a issue on this repository and i'll have a look at it.
