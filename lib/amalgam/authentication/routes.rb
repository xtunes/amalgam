module ActionDispatch::Routing
  class Mapper
    def authentication_for(scope,options={})
      options[:sigin_path] ||= '/signin'
      options[:signout_path] ||= '/signout'
      redirect_after_signin = options[:redirect_after_signin]
      redirect_after_siginout = options[:redirect_after_siginout]
      redirect_after_signin ||= Proc.new { |user| admin_root_url }
      redirect_after_siginout ||= Proc.new { main_app.root_url }
      redirect_after_signin = Proc.new { |user| options[:redirect_after_signin] } if options[:redirect_after_signin].is_a? String
      redirect_after_signin = Proc.new { |user| main_app.send("#{options[:redirect_after_signin]}_url") } if options[:redirect_after_signin].is_a? Symbol
      redirect_after_siginout = Proc.new { options[:redirect_after_siginout] } if options[:redirect_after_siginout].is_a? String
      redirect_after_siginout = Proc.new { main_app.send("#{options[:redirect_after_siginout]}_url") } if options[:redirect_after_siginout].is_a? Symbol
      options[:controller] ||= 'sessions'
      if scope.is_a?(String) || scope.is_a?(Symbol)
        Amalgam.user_model = scope.to_s.safe_constantize
      else
        Amalgam.user_model = scope
      end

      match options[:sigin_path] => "#{options[:controller]}#new", :via => :get, :as => :signin
      match options[:sigin_path] => "#{options[:controller]}#create", :via => :post, :as => :signin
      delete options[:signout_path] => "#{options[:controller]}#destroy", :as => :signout
      match "/#{scope.to_s.tableize.singularize}/edit" => "registrations#edit", :via => :get, :as => :edit_admin
      match "/#{scope.to_s.tableize.singularize}/update" => "registrations#update", :via => :put, :as => :update_admin

      Amalgam::ApplicationController.send(:define_method, :redirect_after_siginout, &redirect_after_siginout)
      Amalgam::ApplicationController.send(:define_method, :redirect_after_signin, &redirect_after_signin)
      Amalgam::ApplicationController.send :include, Amalgam::Authentication::Controllers::Helpers
      ApplicationController.send :include, Amalgam::Authentication::Controllers::Helpers
    end
  end
end