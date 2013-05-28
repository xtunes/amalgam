Amalgam::Engine.routes.draw do

	namespace :admin do
    root :to => 'resources#index', :defaults => { :resources => "pages" }
    post 'editor/upload_image' => 'editor#upload_image'
    put 'editor' => 'editor#update' , :as => 'editor'
	end

  def amalgam_resources(*resources, &block)
    options = resources.extract_options!.dup
    default_actions = ['index','new','edit','create','update','destroy','show']
    options[:only] ||= default_actions
    options[:except] ||= []
    options[:only] = options[:only].map!{|x| x.to_s } - options[:except].map!{|x| x.to_s }
    resources.map!{|x| x.to_s}
    resources.each do |resource|
      Amalgam.admin_menus[resource.to_s] = options[:only]
    end
    options.delete(:except)
    options[:controller] ||= 'resources'
    model = options.delete(:model)

    resources.each do |resource|
      constraint = lambda do |req|
        req.env[:resources] = model ? model : resource
      end
      constraints(constraint) do
        resources(*([resource]<<options)) do
          yield if block_given?

          collection do
            get :search
          end
        end
      end
    end
  end

  get '/attachments/attributes' => "attachments#attributes"
  get '/attachments/:id' => "attachments#show", :as => :attachment
  get '/attachments/:id/download' => "attachments#show", :as => :attachment_download, :defaults => {:download => true}

  instance_eval &Amalgam.routes

  match '/editor(/*requested_uri)' => "admin/editor#edit", :as => :mercury_editor
  mount Mercury::Engine => "/"
end
