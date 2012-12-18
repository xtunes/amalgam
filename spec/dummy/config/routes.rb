require 'page_routes'
Rails.application.routes.draw do

  hierarchical_resource :pages
  resources :posts, :only => [:show]
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:slug => 'home'}
end
