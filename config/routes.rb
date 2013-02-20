Amalgam::Engine.routes.draw do

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

  instance_eval &Amalgam.routes
end
