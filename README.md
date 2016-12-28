# rpi-nginx-sslproxy
Docker container for running an SSL proxy in front of other services on Raspberry Pi

This is a very simple pass-through proxy that adds SSL onto a web site (no URL rewriting).  I find it useful to collect multiple web services into a single endpoint and serve them over SSL.

### Usage
The paths and endpoints to proxy are controlled by the ENDPOINTS environment variable. It should contain a list of path|uri pairs that indicate which path to proxy to which endpoint.  

For instance, to forward /services/service1 to http://service1host and /services/service2 to http://service2host:  
```--env ENDPOINTS="/service/service1|http://service1host /services/service2|http://service2host"```

service1host and service2host can be other containers running on the same docker network as this proxy. You can then expose port 443 of this proxy container on your host and reach both services over SSL.

This container also includes automated TLS certificate requesting from letsencrypt.org. You must ahve a registered domain name, and to authenticate your domain letsencrypt requires you to write out a file into your webroot in a known location for letsencrypt.org to read.  The certificate request, authentication, and installation are all autoamted within this container.  The domain name you are using must have DNS set up to point to the container host and you must have port 80 open to the internet.  This container will serve the one exact path letsencrypt needs to authenticate unencrypted over port 80.

To use the letsencrypt TLS certifiacte process, set the DOMAIN_NAME env variable with your domain:  
```--env DOMAIN_NAME=www.mydomain.com```

On first startup, the container will generate a new dhparams.pem file, which will take a long time to run, ~12 minutes on my rpi 3.

