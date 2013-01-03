Amalgam.setup do |config|
	config.type_whitelist = ['Page','Post']
	config.models_with_templates = ['pages','posts']
  config.authority_model :admin_user, :as => :admin
  config.i18n = 'param'
  config.admin_routes do
    resources :pages, :except => [:show]
    resources :posts, :except => [:show] do
      collection do
        get :test2, :menu_item => true
      end
    end
    match "/signin2" => "session_boxs#new", :via => :get, :as => 'signin2', :menu_item => true
  end
end