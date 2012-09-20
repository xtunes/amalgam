Amalgam::Engine.routes.draw do

  if Amalgam.authorities.present?
    instance_eval <<-METHODS, __FILE__, __LINE__ + 1
      match "/:resource/signin" => "sessions#new", :via => :get, :as => 'signin'
      delete "/:resource/signout" => "sessions#destroy", :as => 'signout'
    METHODS

    Amalgam.authorities.each do |auth_name, type|
      instance_eval <<-METHODS, __FILE__, __LINE__ + 1
        post "/#{auth_name.to_s}/signin" => "sessions#create"
      METHODS
    end
  end

	namespace :admin do
		Amalgam.routes.each do |controller|
      resources *controller[:args], &controller[:block]
    end
    root :to => 'pages#index'
    post 'editor/upload_image' => 'editor#upload_image'
    put 'editor' => 'editor#update' , :as => 'editor'
	end
end
