require 'dragonfly/rails/images'
Amalgam.setup do |config|
	config.type_whitelist = ['Page','Post']
	config.models_with_templates = ['pages','posts']
  config.mercury_link_whitelist = "(^\\\/(zh-CN|en){0,1}\\\/(pages|posts))|(^\\\/$)"
  config.i18n = 'param'
  config.admin_routes do
    namespace :admin do
      amalgam_resources :pages, :except => [:show]
      amalgam_resources :posts
    end
    authentication_for AdminUser, :redirect_after_siginout => :root
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/