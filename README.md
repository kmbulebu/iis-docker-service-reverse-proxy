# iis-docker-service-reverse-proxy

Runs IIS + ARR as a reverse proxy to forward incoming requests to backend
Docker services or containers. The first part of the `Host:` header will determine
the name of the the Docker container to send traffic. Paths and query strings
are preserved and passed to the backend.

This IIS reverse proxy enables a single container to expose a single port (80),
while keeping several web service containers behind in a private network.

There are better alternatives (NGINX, HAProxy, Apache httpd, etc), but the aim
here is to use all Windows technologies which are deemed production ready. 

Examples:

`http://myapp.domain.com/` will forward `/` request to a container with name `myapp`, listening on port 8080.

`http://api.domain.com/` will forward `/` request to a container with name `api`.

`http://service/hello/index.html` will forward `/hello/index.html` request to a container with name `service`.

# Limitations / Warnings

Do not use this. Limitations of Windows Containers and HyperV networking prevent this from working correctly.

## Occasional container exit
Not yet debugged. On several occasionals, the container exitted unexpectedly.

## No Swarm Service Networking VIP mode in Windows
Reference: [https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/swarm-mode]
```
Currently, DNS Round-Robin is the only load balancing strategy supported on Windows.
```

IIS will only resolve the IP addresses of backend services on startup, and will only choose the first IP address chosen. Therefore, all traffic will be sent to a single container, and if that container disappears or is replaced, IIS will fail to deliver traffic.

## No NAT loopback on Windows
Reference: [https://github.com/moby/moby/issues/21558]
Don't let the 'closed' status of this issue fool you. It's still broken, but is being tracked internally at Microsoft. Unfortunately, only a few inside Microsoft know if this will be fixed soon or at all in Windows 2016. 

You might be inclined to use the host's IIS service instead and avoid the VIP mode issue or rely on a single backend container. You will still encounter the VIP issue, but worse, you'll need to discover the IP addresses of the backend service containers through the Docker API. That is because you can not simply use http://localhost:<container port #> to access the exposed port of the Docker container. You must use docker inspect, or the API, to find the internal IP address of that container. 

## Multiple NAT networks broken on Windows 2016
These limitations hsould be better outlined by Microsoft and Docker. You will need to wade through many issues and knowledge base articles to find out that multiple NAT networks are not yet supported on Windows 2016. Windows 10 Creators Update or newer should work. Regardless, you will probably find yourself frequently running powershell commands to reset the networking to work again with Docker compose. Again, it iss difficult to discern if these issues are being worked on for a Windows 2016 update.

```
Note: Multiple NAT networks are now supported with Windows 10 Creators Update!
```

Reference: [https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-networking]

Reference: [https://blogs.technet.microsoft.com/virtualization/2017/02/09/overlay-network-driver-with-support-for-docker-swarm-mode-now-available-to-windows-insiders-on-windows-10/]

Reference: [https://github.com/moby/moby/issues/23314]

Reference: [https://github.com/docker/compose/issues/4024]

Reference: [https://github.com/docker/compose/issues/4818]

## No equivalent to a Linux Socket for Windows Containers
I am still researching this to verify. A common pattern to enable a container to access the Docker API is to bind mount `/var/run/docker.sock` into the container. This enables some load balancer/reverse proxy solutions to perform service discovery. Traefik, a popular Docker Swarm aware reverse proxy, is written in Go and has binaries for Windows. An equivalent is not yet available for Windows Containers. Unfortunately, you will need to enable the Docker daemon to listen on a TCP port, but this has issues. First, you should always protect the port with TLS certificate authentication. Next, you'll rely only on local and network firewalls to protect this socket. Finally, you'll need to deal with finding the host's IP/hostname from within the container as, depending on configuration, may vary from container to container and host to host. 

# Recommendations

- Embrace Linux. You'll need it to run your container ecosystem. Consider log aggregation, metrics, monitoring, etc as well.
- There are many better solutions, using Linux, for reverse proxies. Many with service discovery.
  - NGINX
  - Traefik
  - HAProxy
  - Apache httpd
  - Roll your own API gateway (e.g. Zuul/Ribbon/Eureka )
- Run .NET core on Linux.

