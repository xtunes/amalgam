module ActionDispatch::Routing
  class Mapper
    def hierarchical_for(scope,options = {})
      mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
      get "/#{scope.to_s}/*path" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
    end

    def models_routes
      Amalgam.routes.each do |controller|
        resources *controller[:args], &controller[:block]
      end
    end

    def resource_routes
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
  end
end