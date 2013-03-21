Rails.application.routes.draw do
  resources :pages, :only => [:show]
  resources :posts, :only => [:show]
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:id => 'home'}
end
