# Postgres DB with PGAdmin

Use the `.env.template` to create your own `.env` file containing the overridden values.

Make sure the volumes are created before running `docker compose up`.

To connect to the Postgres database from pgAdmin, use `postgres` as the host name. This is the service key from the yml file, which maps to the IP address of the Postgres container.
Use the shell script to start or stop the services.
