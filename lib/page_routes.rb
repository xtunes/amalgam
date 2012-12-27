module ActionDispatch::Routing
  class Mapper
    def globalize_hierarchical_resource(scope,locales,options = {})
      mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
      if Amalgam.i18n == 'param'
        scope "(:locale)", :locale => locales do
          get "/#{scope.to_s}/*slug" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
        end
      end
      get "/#{scope.to_s}/*slug" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym, :constraints => { :subdomain => locales } if Amalgam.i18n == 'subdomain'
    end

    def hierarchical_resource(scope,options = {})
      mount Mercury::Engine => options[:mercury] || "/" if options[:mercury] != false
      get "/#{scope.to_s}/*slug" => "#{scope.to_s}#show" , :as => scope.to_s.singularize.to_sym
    end
  end
end