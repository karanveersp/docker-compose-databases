# add admin user
rabbitmqctl add_user mq-admin mqadmin1

# add admin tag to admin user
rabbitmqctl set_user_tags mq-admin administrator

# change default guest password
rabbitmqctl change_password guest guest121

# add dev user
rabbitmqctl add_user mq-dev mqdeveloper1

# add dev vhost (isolated environment for queues)
rabbitmqctl add_vhost mq-dev-vhost

# set admin permissions on vhost
rabbitmqctl set_permissions -p mq-dev-vhost mq-admin ".*" ".*" ".*"

# set dev permissions on vhost
rabbitmqctl set_permissions -p mq-dev-vhost mq-dev ".*" ".*" ".*"