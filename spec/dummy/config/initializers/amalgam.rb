Amalgam.setup do |config|
	config.type_whitelist = ['Page','Post']
	config.resources :pages, :except => [:show]
	config.resources :posts, :except => [:show]
  config.authority_model :admin_user, :as => :admin
end