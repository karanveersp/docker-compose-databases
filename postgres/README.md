# Postgres DB with PGAdmin

Use the `.env.template` to create your own `.env` file containing the overridden values.

Make sure the volumes are created before running `docker compose up`.

To connect to the Postgres database from pgAdmin, use `postgres` as the host name. This is the service key from the yml file, which maps to the IP address of the Postgres container.
Use the shell script to start or stop the services.

# Network

Use a shared network created with docker network create if you want different docker compose services running as separate containers communicating over the same network and able to reference different service ip addresses by just their service name key.

`docker network create shared_network`

# Connection

`docker run -it --rm postgres psql -h <hostname> -U <username>`
