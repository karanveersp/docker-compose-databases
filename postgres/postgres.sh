#!/bin/bash

# Function to start the containers
start_containers() {
    echo "Starting postgres/pgadmin containers..."
    docker-compose up -d
    echo "Containers started."
}

# Function to stop the containers
stop_containers() {
    echo "Stopping postgres/pgadmin containers..."
    docker-compose down
    echo "Containers stopped."
}

# Check the command line argument
if [ "$1" == "start" ]; then
    start_containers
elif [ "$1" == "stop" ]; then
    stop_containers
else
    echo "Usage: $0 {start|stop}"
fi