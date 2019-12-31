Rails.application.routes.draw do
  resources :articles do
    get 'search', on: :collection
  end
  root 'articles#index'
end
