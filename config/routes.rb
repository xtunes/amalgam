Amalgam::Engine.routes.draw do

	namespace :admin do
    resources :groups
    root :to => 'resources#index', :defaults => { :resources => "pages" }
    post 'editor/upload_image' => 'editor#upload_image'
    put 'editor' => 'editor#update' , :as => 'editor'
	end

  def amalgam_resources(*resources, &block)
    options = resources.extract_options!.dup
    options[:only] ||= ['index','new','edit','create','update','destroy','search']
    options[:except] ||= []
    options[:only] = options[:only].map!{|x| x.to_s } - options[:except].map!{|x| x.to_s }
    resources.map!{|x| x.to_s}
    resources.each do |resource|
      Amalgam.admin_menus[resource.to_s] = options[:only]
    end

    scope '/:resources', :constraints => lambda{|req| resources.include?(req.path_parameters[:resources].to_s) } do

      get '' => 'resources#index', :as => :resources if options[:only].include?('index')
      get 'search' => 'resources#search', :as => :search_resources if options[:only].include?('search')
      get 'new' => 'resources#new', :as => :new_resource if options[:only].include?('new')
      get '/:id/edit' => 'resources#edit', :as => :edit_resource if options[:only].include?('edit')
      post '/create' => 'resources#create', :as => :create_resource if options[:only].include?('create')
      put '/:id' => 'resources#update', :as => :update_resource if options[:only].include?('update')
      delete '/:id' => 'resources#destroy', :as => :resource if options[:only].include?('destroy')
    end

    self
  end

  instance_eval &Amalgam.routes
end
