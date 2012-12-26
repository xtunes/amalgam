module ActionDispatch::Routing
  class Mapper
    def hierarchical_resource(scope,locales,options = {})
      mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
      scope "(:locale)", :locale => locales do
        get "/#{scope.to_s}/*slug" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
      end
    end
  end
end