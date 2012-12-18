module ActionDispatch::Routing
  class Mapper
    def hierarchical_resource(scope,options = {})
      mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
      get "/#{scope.to_s}/*slug" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
    end
  end
end