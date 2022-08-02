```bash
docker compose up -d
```

To initialize the users/admins

```bash
docker cp ./setup.sh rabbitmq:/
docker exec -it rabbitmq sh
./setup.sh
```
