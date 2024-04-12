
#!/bin/bash


ssh node-0 'containerid=$(docker ps -aqf "name=^socialNetwork_user-mongodb"); docker update --cpuset-cpus "1-4" $containerid'
ssh node-0 'containerid=$(docker ps -aqf "name=^socialNetwork_home-timeline-service"); docker update --cpuset-cpus "6" $containerid'

ssh node-1 'containerid=$(docker ps -aqf "name=^socialNetwork_post-storage-mongodb"); docker update --cpuset-cpus 2 $containerid'
ssh node-1 'containerid=$(docker ps -aqf "name=^socialNetwork_post-storage-service"); docker update --cpuset-cpus "6" $containerid'
ssh node-1 'containerid=$(docker ps -aqf "name=^socialNetwork_media-memcached"); docker update --cpuset-cpus 7 $containerid'

ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_post-storage-memcached"); docker update --cpuset-cpus 1 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_media-service"); docker update --cpuset-cpus 2 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_compose-post-service"); docker update --cpuset-cpus 3 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_home-timeline-redis"); docker update --cpuset-cpus 4 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_user-mention-service"); docker update --cpuset-cpus 5 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_social-graph-mongodb"); docker update --cpuset-cpus 6 $containerid'
ssh node-2 'containerid=$(docker ps -aqf "name=^socialNetwork_url-shorten-service"); docker update --cpuset-cpus 7 $containerid'

ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_text-service"); docker update --cpuset-cpus 2 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_url-shorten-memcached"); docker update --cpuset-cpus 3 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_media-mongodb"); docker update --cpuset-cpus 4 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_social-graph-service"); docker update --cpuset-cpus 5 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_media-frontend"); docker update --cpuset-cpus 6 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_user-timeline-redis"); docker update --cpuset-cpus 7 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_cpu-intensive"); docker update --cpuset-cpus 7 $containerid'
ssh node-3 'containerid=$(docker ps -aqf "name=^socialNetwork_io-intensive"); docker update --cpuset-cpus 7 $containerid'

ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_user-memcached"); docker update --cpuset-cpus 2 $containerid'
ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_social-graph-redis"); docker update --cpuset-cpus 3 $containerid'
ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_user-service"); docker update --cpuset-cpus 4 $containerid'
ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_user-timeline-mongodb"); docker update --cpuset-cpus 5 $containerid'
ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_user-timeline-service"); docker update --cpuset-cpus 6 $containerid'
ssh node-4 'containerid=$(docker ps -aqf "name=^socialNetwork_unique-id-service"); docker update --cpuset-cpus 7 $containerid'

ssh node-5 'containerid=$(docker ps -aqf "name=^socialNetwork_url-shorten-mongodb"); docker update --cpuset-cpus 1 $containerid'
ssh node-5 'containerid=$(docker ps -aqf "name=^socialNetwork_nginx-web-server"); docker update --cpuset-cpus "2-9" $containerid'

## example of how to replay back the collectl results
#collectl -scdn -p ./VMelba9-20130922-083628.raw  -P -f . -oUmz --from 20130922:08:36-08:39
