Rails.application.routes.draw do

  globalize_hierarchical_resource :pages, /zh-cn|en/
  resources :posts, :only => [:show]
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:slug => 'home'}
  match '/:locale' => 'pages#show' , :defaults => {:slug => 'home'}
end
