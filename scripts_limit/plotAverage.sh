#!/bin/bash
# shungeng
# plot each collectl info by server
#


# user-defined variables
#output_name=collectl.pdf
#title_name=
#timestamp_offset=0

cp ../scripts_limit/plotAverage.gnu .

# cli options

rm average_resource_utilization.csv
rm average_performance.csv
rm average_utilization_VM0.csv
rm average_utilization_VM1.csv
rm average_utilization_VM2.csv
rm average_utilization_VM3.csv
rm average_utilization_VM4.csv

echo workload,home_timeline_service,user_mongodb,post_storage_service,post_storage_mongodb,media_memcached,post_storage_memcached,compose_post_service,media_service,user_mention_service,home_timeline_redis,social_graph_mongodb,url_shorten_service,user_timeline_redis,text_service,media_mongodb,social_graph_service,url_shorten_memcached,media_frontend,unique_id_service,user_timeline_service,user_memcached,user_timeline_mongodb,user_service,social_graph_redis,url_shorten_mongodb,nginx_web_server,nginx_front > average_resource_utilization.csv

echo workload,userMongodb,homeTimelineService > average_utilization_VM0.csv
echo workload,postStorageService,postStorageMongodb,mediaMemcached > average_utilization_VM1.csv
echo workload,postStorageMemcached,mediaService,composePostService,homeTimelineRedis,userMentionService,socialGraphMongodb,urlShortenService > average_utilization_VM2.csv
echo workload,textService,urlShortenMemcached,mediaMongodb,socialGraphService,userTimelineRedis > average_utilization_VM3.csv
echo workload,userMemcached,socialGraphRedis,userService,userTimelineMongodb,userTimelineService,uniqueIdService > average_utilization_VM4.csv
echo workload,urlShortenMongodb,nginxWebServer > average_utilization_VM5.csv

echo workload,Throughput,Response > average_performance.csv

for i in $( ls -d */ )
do
	cd $i

	for j in $( ls -d */ )
	do
		cd $j
		# gnuplot template file
		con_file=$(ls detailRT-client_*.csv)
		concurrency=$(echo $con_file | egrep -o '[0-9]+')
		pidFile="PID_details.pdf"

		home_timeline_service=`pdfgrep "node-0-HomeTimelineService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_mongodb=`pdfgrep "node-0-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`

		post_storage_service=`pdfgrep "node-1-PostStorageService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		post_storage_mongodb=`pdfgrep "node-1-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		media_memcached=`pdfgrep "node-1-memcached" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`

		post_storage_memcached=`pdfgrep "node-2-memcached" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		compose_post_service=`pdfgrep "node-2-ComposePostService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		media_service=`pdfgrep "node-2-MediaService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_mention_service=`pdfgrep "node-2-UserMentionService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		home_timeline_redis=`pdfgrep "node-2-redis-server" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		social_graph_mongodb=`pdfgrep "node-2-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		url_shorten_service=`pdfgrep "node-2-UrlShortenService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`

		user_timeline_redis=`pdfgrep "node-3-redis-server" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		text_service=`pdfgrep "node-3-TextService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		media_mongodb=`pdfgrep "node-3-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		social_graph_service=`pdfgrep "node-3-SocialGraphService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		url_shorten_memcached=`pdfgrep "node-3-memcached" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		media_frontend=`pdfgrep "node-3-nginx" $pidFile |  egrep -o '[0-9]+[.][0-9]+' | awk '{n += $1}; END{print n}'`

		unique_id_service=`pdfgrep "node-4-UniqueIdService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_timeline_service=`pdfgrep "node-4-UserTimelineService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_memcached=`pdfgrep "node-4-memcached" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_timeline_mongodb=`pdfgrep "node-4-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		user_service=`pdfgrep "node-4-UserService" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		social_graph_redis=`pdfgrep "node-4-redis-server" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`

		url_shorten_mongodb=`pdfgrep "node-5-mongod" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`
		nginx_web_server=`pdfgrep "node-5-nginx:" $pidFile |  egrep -o '[0-9]+[.][0-9]+' | awk '{n += $1}; END{print n}'`

		nginx_front=`pdfgrep "node-6-nginx:" $pidFile |  egrep -o '[0-9]+[.][0-9]+'`

		echo $concurrency','$home_timeline_service','$user_mongodb','$post_storage_service','$post_storage_mongodb','$media_memcached','$post_storage_memcached','$compose_post_service','$media_service','$user_mention_service','$home_timeline_redis','$social_graph_mongodb','$url_shorten_service','$user_timeline_redis','$text_service','$media_mongodb','$social_graph_service','$url_shorten_memcached','$media_frontend','$unique_id_service','$user_timeline_service','$user_memcached','$user_timeline_mongodb','$user_service','$social_graph_redis','$url_shorten_mongodb','$nginx_web_server','$nginx_front >> ../../average_resource_utilization.csv







	
		pdfFile=RT_Q_conn_WL$concurrency.pdf

		userMongodbCPU=`pdfgrep "userMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		homeTimelineServiceCPU=`pdfgrep "homeTimelineService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`

		postStorageMongodbCPU=`pdfgrep "postStorageMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		mediaMemcachedCPU=`pdfgrep "mediaMemcached"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1` 
		postStorageServiceCPU=`pdfgrep "postStorageService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`

		postStorageMemcachedCPU=`pdfgrep "postStorageMemcached"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		mediaServiceCPU=`pdfgrep "mediaService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		composePostServiceCPU=`pdfgrep "composePostService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		homeTimelineRedisCPU=`pdfgrep "homeTimelineRedis"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		userMentionServiceCPU=`pdfgrep "userMentionService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`
		socialGraphMongodbCPU=`pdfgrep "socialGraphMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`
		urlShortenServiceCPU=`pdfgrep "urlShortenService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`

		textServiceCPU=`pdfgrep "textService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		urlShortenMemcachedCPU=`pdfgrep "urlShortenMemcached"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		mediaMongodbCPU=`pdfgrep "mediaMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		socialGraphServiceCPU=`pdfgrep "socialGraphService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`
		userTimelineRedisCPU=`pdfgrep "userTimelineRedis"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`

		userMemcachedCPU=`pdfgrep "userMemcached"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		socialGraphRedisCPU=`pdfgrep "socialGraphRedis"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		userServiceCPU=`pdfgrep "userService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		userTimelineMongodbCPU=`pdfgrep "userTimelineMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`
		userTimelineServiceCPU=`pdfgrep "userTimelineService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`
		uniqueIdServiceCPU=`pdfgrep "uniqueIdService"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`

		urlShortenMongodbCPU=`pdfgrep "urlShortenMongodb"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -1 | tail -1`
		nginxWebServerCPU=`pdfgrep "nginxWebServer"  $pdfFile | egrep -o '[0-9]+[.][0-9]+' | head -2 | tail -1`


		#echo $concurrency','$user_mongodb','$home_timeline_service >> ../average_resource_utilization_VM0.csv
		#echo $concurrency','$post_storage_mongodb','$post_storage_service1','$post_storage_service2','$post_storage_service3','$post_storage_service4','$media_memcached >> ../average_resource_utilization_VM1.csv
		#echo $concurrency','$post_storage_memcached','$media_service','$compose_post_service','$home_timeline_redis','$user_mention_service','$social_graph_mongodb','url_shorten_service >> ../average_resource_utilization_VM2.csv
		#echo $concurrency','$text_service','$url_shorten_memcached','$media_mongodb','$social_graph_service','$media_frontend','$user_timeline_redis >> ../average_resource_utilization_VM3.csv
		#echo $concurrency','$user_memcached','$social_graph_redis','$user_service','$user_timeline_mongodb','$user_timeline_service','$unique_id_service >> ../average_resource_utilization_VM4.csv
		#echo $concurrency','$url_shorten_mongodb','$nginx_web_server1','$nginx_web_server2','$nginx_web_server2','$nginx_web_server3','$nginx_web_server4','$nginx_web_server5','$nginx_web_server6 >> ../average_resource_utilization_VM5.csv
		#echo $concurrency','$homeTimelineService_CPU','$cassandra_CPU','$postStorageMemcached_CPU','$postStorageService_CPU','$jaegerCollector_CPU','$ngixWebServer_CPU','$userTimelineService_CPU >> ../average_utilization.csv
		
		echo $concurrency','$userMongodbCPU','$homeTimelineServiceCPU >> ../../average_utilization_VM0.csv
		echo $concurrency','$postStorageMongodbCPU','$mediaMemcachedCPU','$postStorageServiceCPU >> ../../average_utilization_VM1.csv
		echo $concurrency','$postStorageMemcachedCPU','$mediaServiceCPU','$composePostServiceCPU','$homeTimelineRedisCPU','$userMentionServiceCPU','$socialGraphMongodbCPU','$urlShortenServiceCPU >> ../../average_utilization_VM2.csv
		echo $concurrency','$textServiceCPU','$urlShortenMemcachedCPU','$mediaMongodbCPU','$socialGraphServiceCPU','$userTimelineRedisCPU >> ../../average_utilization_VM3.csv
		echo $concurrency','$userMemcachedCPU','$socialGraphRedisCPU','$userServiceCPU','$userTimelineMongodbCPU','$userTimelineServiceCPU','$uniqueIdServiceCPU >> ../../average_utilization_VM4.csv
		echo $concurrency','$urlShortenMongodbCPU','$nginxWebServerCPU >> ../../average_utilization_VM5.csv
		

		client_TP=`pdfgrep "client-TP"  $pdfFile | egrep -o '[0-9]+[.][0-9]+'`
		client_RT=`pdfgrep "client-RT"  $pdfFile | egrep -o '[0-9]+[.][0-9]+'`

		echo $concurrency','$client_TP','$client_RT >> ../../average_performance.csv

		cd ..
	done
	cd ..
done

gnuplot plotAverage.gnu
