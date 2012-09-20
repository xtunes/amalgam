Amalgam::Engine.routes.draw do
	namespace :admin do
		models_routes
    root :to => 'pages#index'
    post 'editor/upload_image' => 'editor#upload_image'
    put 'editor' => 'editor#update' , :as => 'editor'
	end
  resource_routes if Amalgam.authorities.present?
end
