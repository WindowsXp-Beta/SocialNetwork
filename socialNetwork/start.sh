#!/bin/bash

start() {
    docker stack deploy -c docker-compose-swarm.yml socialNetwork
}

dockerPS() {
    docker stack ps socialNetwork
}

dockerServices() {
    docker stack services socialNetwork
}

shut() {
    docker stack rm socialNetwork
}

register() {
    python3 scripts/init_social_graph.py --graph=socfb-Reed98
}

compose() {
    ../wrk2/wrk -D exp -t 100 -c 100 -d 100 -L -s ./wrk2/scripts/social-network/compose-post.lua http://localhost:8080/wrk2-api/post/compose -R 100
}

dedicate() {
    ./scripts/dedicate.sh
}

all() {
    start
    sleep 10
    register
    sleep 10
    compose
    dedicate
}

stop() {
    ./scripts/stopall.sh
}

$1 $2 $3