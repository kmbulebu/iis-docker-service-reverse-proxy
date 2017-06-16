# iis-docker-service-reverse-proxy

Runs IIS + ARR as a reverse proxy to forward incoming requests to backend
Docker services or containers. The first part of the `Host:` header will determine
the name of the the Docker container to send traffic. Paths and query strings
are preserved and passed to the backend.

This IIS reverse proxy enables a single container to expose a single port (80),
while keeping several web service containers behind in a private network.

Examples:

`http://myapp.domain.com/` will forward `/` request to a container with name `myapp`.

`http://api.domain.com/` will forward `/` request to a container with name `api`.

`http://service/hello/index.html` will forward `/hello/index.html` request to a container with name `service`.
