module ActionDispatch::Routing
  class Mapper
    def hierarchical_for(scope,options = {})
    	mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
    	get "/#{scope.to_s}/*path" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
    end

    def models_routes
    	Amalgam.routes.each do |controller|
    		resources *controller[:args], &controller[:proc]
    	end
    end
  end
end