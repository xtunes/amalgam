Amalgam.setup do |config|
	config.type_whitelist = ['Page','Post']
	config.models_with_templates = ['pages','posts']
  config.i18n = 'param'
  config.admin_routes do
    namespace :admin do
      resources :pages, :except => [:show]
      resources :posts, :except => [:show] do
        collection do
          get :test2, :menu_item => true
        end
      end
    end
    authentication_for AdminUser, :redirect_after_siginout => :root
  end
end