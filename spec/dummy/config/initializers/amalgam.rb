require 'dragonfly/rails/images'
Amalgam.setup do |config|
	config.type_whitelist = ['Page','Post']
	config.models_with_templates = ['pages','posts']
  config.admin_routes do
    namespace :admin do
      resources :pages, :except => [:show]
      resources :posts, :except => [:show]
    end
    authentication_for AdminUser, :redirect_after_siginout => :root
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/