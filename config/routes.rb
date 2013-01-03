Amalgam::Engine.routes.draw do

  if Amalgam.authorities.present?
    instance_eval <<-METHODS, __FILE__, __LINE__ + 1
      match "/:resource/signin" => "sessions#new", :via => :get, :as => 'signin'
      delete "/:resource/signout" => "sessions#destroy", :as => 'signout'
      match "/:resource/signup" => "registrations#new", :via => :get, :as => 'signup'
      match "/:resource/edit" => "registrations#edit", :via => :get, :as => 'edit_info'
    METHODS

    Amalgam.authorities.each do |auth_name, type|
      instance_eval <<-METHODS, __FILE__, __LINE__ + 1
        post "/#{auth_name.to_s}/signin" => "sessions#create"
        post "/#{auth_name.to_s}/signup" => "registrations#create"
        put "/#{auth_name.to_s}/edit_info" => "registrations#update"
      METHODS
    end
  end

	namespace :admin do
    resources :groups
    root :to => 'pages#index'
    post 'editor/upload_image' => 'editor#upload_image'
    put 'editor' => 'editor#update' , :as => 'editor'
	end

  def match(path, *rest)
    path[:menu_item] ||= false if path.is_a? Hash
    default_actions = [:new,:index]
    if parent_resource
      Amalgam.admin_menus[@scope[:controller]] ||= parent_resource.actions & default_actions
      Amalgam.admin_menus[@scope[:controller]] << (rest.first[:as] || path) if rest.present? && rest.first.delete(:menu_item)
    else
      if path.is_a?(Hash) && path.delete(:menu_item)
        name = path[:as] ? path[:as] : path.keys.first.split('/').last
        if name.present?
          Amalgam.admin_menus[name] = []
          Amalgam.admin_menus[name] << {:controller => path.first[1].split("#").first}
        end
      end
    end
    super(path,*rest)
  end

  namespace :admin do
    instance_eval &Amalgam.routes
  end
end
