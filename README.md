# Docker Compose Databases

This repo contains docker compose files for various databases and services.

The volumes where persistent data is stored are external named volumes.

Create them once before starting the services.

Example:
`docker volume create postgres_volume`
`docker volume create mongodb_volume`

To run each container:

`docker compose up -d`
