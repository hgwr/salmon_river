# salmon_river - elasticsearch-rails 勉強用 Rails App

https://github.com/elastic/elasticsearch-rails と ElasticSearch を使ってみるテスト

* Ruby version: 2.6.5

* System dependencies

- ElasticSearch
- MySQL

* Configuration

** ElasticSearch and Kibana

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

* Database creation

```
bundle exec rake db:create
```

* Database initialization

```
bundle exec rake db:migrate
bundle exec rake load_wikipedia:xml[/Users/hgwr/Documents/corpus/first-million-lines-jawiki-20191220-pages-articles-multistream.xml,1000]
bundle exec rails c
> Article.__elasticsearch__.create_index!
> Article.import
```

* How to run the test suite

```
bundle exec rspec
```
