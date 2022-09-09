# Docker Compose Databases

This repo contains docker compose files for various databases.

For PostGres, the defaults are as follows:
- Postgres user: `postgres`
- Postgres pw: `password`
- PgAdmin username: `admin@admin.com`
- PgAdmin pw: `admin`
- PgAdmin url: `http://localhost:5050`

MongoDB:
- Username: root
- Password password
- Url: `http://localhost:27017`

The volumes where database data is stored are external named volumes called `postgres_volume`, and `mongodb_volume`.

Create them once before starting this container with the commands:

`docker volume create --name postgres_volume`
`docker volume create --name mongodb_volume`

To run each container:

`docker compose up -d`

To create a connection to the postgres db from pgadmin, use `pg_container` as the host name (container name maps to the ip address of the postgres container).
