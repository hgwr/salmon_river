json.extract! article, :id, :title, :content, :revision_timestamp, :created_at, :updated_at
json.url article_url(article, format: :json)
