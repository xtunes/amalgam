require 'page_routes'
Rails.application.routes.draw do

  hierarchical_for :pages
  resources :posts, :only => [:show]
  mount Amalgam::Engine => "/amalgam"
end
