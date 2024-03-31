# Nginx

This nginx service will mount the `./nginx-config` as the runtime config directory so any `.conf` files will be processed.
This config is based on the tutorial here: https://mindsers.blog/en/post/https-using-nginx-certbot-docker/

# Certbot

The certbot service is used to issue certificates for any subdomains you create. Launch `docker compose up` and then run the following in a different shell.

```sh
docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d sub.domain.tdl
```

Remove the `--dry-run` flag and rerun when successful.

After the certification, be sure to copy the new certificates to the local host folder for safe keeping.

# Copying certificates from the container to local host

Use this command:

`docker cp <containerid>:/etc/nginx/ssl/live/ ./certs/` 

# Reloading Nginx Configuration

When making changes to Nginx config files, apply the changes by reloading Nginx within the container.

`docker exec nginx-container nginx -s reload`

This reloads the config without restarting the container.

# Renew certificates

Every 3 months, run the following to renew all certificates.

```sh
docker compose run --rm certbot renew
```

# Overview of docker compose file

```yml
services:
  nginx:
    image: nginx:latest
    container_name: nginx-container
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - ./nginx-config/:/etc/nginx/conf.d/:ro
      - ./proxy_params:/etc/nginx/proxy_params:ro
      - ./certbot/www:/var/www/certbot/:ro
      - ./certbot/conf/:/etc/nginx/ssl/:ro
    networks:
      - shared_network
  certbot:
    image: certbot/certbot:latest
    volumes:
      - ./certbot/www/:/var/www/certbot/:rw
      - ./certbot/conf/:/etc/letsencrypt/:rw
    networks:
      - shared_network
networks:
  shared_network:
    external: true
```

This Docker Compose file defines two services: `nginx` and `certbot`. 

The `nginx` service uses the latest version of the nginx image. It is named `nginx-container`. It exposes ports 80 and 443 to the host machine. The `restart: always` directive ensures that the container will always restart if it stops. If it is manually stopped, it is restarted only when Docker daemon starts or the container itself is manually restarted.

The `volumes` directive is used to mount directories from the host machine to the container. Here, four directories are mounted:

- `./nginx-config/` on the host is mounted to `/etc/nginx/conf.d/` in the container. The `:ro` at the end means the volume is read-only inside the container.
- `./proxy_params` on the host is mounted to `/etc/nginx/proxy_params` in the container, also as read-only.
- `./certbot/www/` on the host is mounted to `/var/www/certbot/` in the container, as read-only.
- `./certbot/conf/` on the host is mounted to `/etc/nginx/ssl/` in the container, as read-only.

The `networks` directive is used to connect this service to the `shared_network` network.

The `certbot` service uses the latest version of the certbot/certbot image. It mounts two directories from the host to the container:

- `./certbot/www/` on the host is mounted to `/var/www/certbot/` in the container. The `:rw` at the end means the volume is read-write inside the container.
- `./certbot/conf/` on the host is mounted to `/etc/letsencrypt/` in the container, also as read-write.

The `certbot` service is also connected to the `shared_network` network.

Finally, the `networks` directive at the bottom of the file declares `shared_network` as an external network, meaning it is not defined in this Compose file and must exist beforehand.



# Nginx config


```conf
server {
    listen 80;
    listen [::]:80;

    server_name sub.domain.tld www.sub.domain.tld;

    location /.well-known/acme-challenge/ {
	    root /var/www/certbot;
    }

    location / {
	    return 301 https://sub.domain.tld$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    http2 on;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    server_tokens off;

    server_name sub.domain.tld;

    ssl_certificate /etc/nginx/ssl/live/sub.domain.tld/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/sub.domain.tld/privkey.pem;

    location / {
	    proxy_pass http://container_service:80;
	    include /etc/nginx/proxy_params;
    }
}
```


This Nginx configuration file defines two server blocks:

1. The first server block listens on port 80 for both IPv4 and IPv6. It is configured to respond to requests for `sub.domain.tld` and `www.sub.domain.tld`. It has two location blocks:

   - The first location block serves Let's Encrypt's ACME challenge files from the `/var/www/certbot` directory. This is used for automated certificate renewal.
   - The second location block redirects all other requests to the HTTPS version of the site (`https://sub.domain.tld`).

2. The second server block listens on port 443 (the standard HTTPS port) for both IPv4 and IPv6. It also enables HTTP/2. It responds to requests for `sub.domain.tld`. It uses SSL certificates located at `/etc/nginx/ssl/live/sub.domain.tld/fullchain.pem` and `/etc/nginx/ssl/live/sub.domain.tld/privkey.pem`. All requests are proxied to `http://container_service:80`, a service running in another Docker container.

   - The `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;` line adds the HTTP Strict Transport Security (HSTS) header to responses. This tells browsers to only use HTTPS for this domain for the next year (31536000 seconds).
   - The `server_tokens off;` line prevents Nginx from revealing its version number in error messages and in the “Server” response header field.


Whenever adding a new subdomain with ssl support, define these two server blocks.


# Proxy params

The `proxy_params` file sets up HTTP headers that are added to requests that are forwarded from the Nginx proxy to the backend servers. Here's what each line does:

1. `proxy_set_header Host $host;`: This line sets the `Host` header of the proxied request to the same value as the original request received by Nginx. This is useful when your backend server needs to know the original host name.

2. `proxy_set_header X-Real-IP $remote_addr;`: This line sets the `X-Real-IP` header to the IP address of the client making the original request. This is useful when your backend server needs to know the IP address of the original client, not the IP address of the Nginx proxy.

3. `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`: This line sets the `X-Forwarded-For` header to the client's IP address. This header is a list of IP addresses, where each proxy that the request goes through adds the IP address where it received the request from. This can be useful for tracking the chain of proxies that a request went through.

4. `proxy_set_header X-Forwarded-Proto $scheme;`: This line sets the `X-Forwarded-Proto` header to the protocol (`http` or `https`) of the original request. This is useful when your backend server needs to know the original protocol, especially when it needs to generate absolute URLs.

Including this `proxy_params` file in an Nginx server block allows these headers to be set for all proxied requests handled by that server block.