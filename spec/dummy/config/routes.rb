require 'page_routes'
Rails.application.routes.draw do

  hierarchical_resource :pages, /zh-CN|en/
  resources :posts, :only => [:show]
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:slug => 'home'}
  match '/:locale' => 'pages#show' , :defaults => {:slug => 'home'}
end
