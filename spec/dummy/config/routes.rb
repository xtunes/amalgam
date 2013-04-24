Rails.application.routes.draw do
  scope "(:locale)", :locale => /zh-cn|zh-CN|en/ do
    resources :pages, :only => [:show]
    resources :posts, :only => [:show]
  end
  mount Amalgam::Engine => '/'
  root :to => 'pages#show' , :defaults => {:id => 'home', :locale => 'en'}
  match '/:locale' => 'pages#show' , :defaults => {:id => 'home'}
end
