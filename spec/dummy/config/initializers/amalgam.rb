Amalgam.setup do |config|
	config.type_whitelist = ['Page']
	config.resources :pages, :except => [:show]
	config.resources :posts, :except => [:show]
end