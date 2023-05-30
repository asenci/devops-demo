# DevOps Demo

## Pending

- [x] MVP Docker image
- [x] Local development environment
- [x] CI job to test building the docker image
- [ ] Linters
- [ ] Deployment script
- [ ] TLS support
- [ ] Monitoring
- [ ] CD pipeline

## Local development with Docker

### Dependencies

#### Docker Desktop

Download and install Docker Desktop from: https://www.docker.com/products/docker-desktop/

On Windows use the WSL 2 backend.

### Starting

To start the development environment:

```shell
docker compose up
```

The following endpoints are available:

- http://localhost/ (Main website)

### Monitoring

To monitor the containers status and logs, use the Docker Desktop dashboard or the following commands:

- To list the status of the containers:

```shell
docker compose ps
```

- To monitor the logs (press CTRL+C to stop):

```shell
docker compose logs --tail=0 --follow
```

### Stopping

To stop the development environment:

```shell
docker compose down
```

### Cleaning up

To clean up the Docker Compose resources:

```shell
docker compose down --volumes --remove-orphans
```
