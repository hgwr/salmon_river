# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ElasticSearch and Kibana

```
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.5.1
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.5.1
```

see http://localhost:9200/

```
docker pull docker.elastic.co/kibana/kibana:7.5.1
docker run --name kibana --link elasticsearch:elasticsearch -p 5601:5601 docker.elastic.co/kibana/kibana:7.5.1
```

see http://localhost:5601/

