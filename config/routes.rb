Rails.application.routes.draw do
  post :file, to: 'files#create'
  get 'files/:tag_search_query/:page', to: 'files#search'
end
