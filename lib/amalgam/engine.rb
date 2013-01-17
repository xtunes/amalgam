module Amalgam
  class Engine < ::Rails::Engine
    isolate_namespace Amalgam

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( amalgam/admin.js amalgam/admin.css amalgam/editor.css amalgam/editor.js )
    end

    initializer "amalgam.params.filter" do |app|
      app.config.filter_parameters += [:password, :password_confirmation, :current_password]
    end

    #https://gist.github.com/1464315
    initializer "error_view" do |config|
      ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
       html = %(<div class="field_with_errors">#{html_tag}</div>).html_safe
       # add nokogiri gem to Gemfile
       elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input"
       elements.each do |e|
         if e.node_name.eql? 'label'
           html = %(<div class="error">#{e}</div>).html_safe
         elsif e.node_name.eql? 'input'
           if instance.error_message.kind_of?(Array)
             html = %(<div class="error">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message.join(',')}</span></div>).html_safe
           else
             html = %(<div class="error">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message}</span></div>).html_safe
           end
         end
       end
       html
      end
    end

    #http://stackoverflow.com/questions/8797690/rails-3-1-better-way-to-expose-an-engines-helper-within-the-client-app
    initializer 'Amalgam.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Amalgam::Admin::LayoutHelper
        helper Amalgam::Editor::EditorHelper
        helper Amalgam::Editor::PropertiesBuilderHelper
        helper Amalgam::AttachmentsHelper
        helper Amalgam::PagesHelper
        helper Amalgam::UrlHelper if Amalgam.i18n
      end
    end
  end
end