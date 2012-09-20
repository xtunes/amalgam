require 'page_routes'
Rails.application.routes.draw do

  hierarchical_for :pages
  resources :posts, :only => [:show]
  mount Amalgam::Engine => Amalgam.scope
  root :to => 'pages#show' , :defaults => {:path => 'home'}
end
