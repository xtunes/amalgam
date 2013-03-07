require 'page_routes'
Rails.application.routes.draw do

  mount Mercury::Engine => "/"
  resources :pages, :only => [:show]
  resources :posts, :only => [:show]
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:id => 'home'}
end
