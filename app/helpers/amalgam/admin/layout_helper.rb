module Amalgam
	module Admin::LayoutHelper
    def menu_item(title, path="#", options={})
      content_tag(:li, :class => is_active?(path,options)) do
        link_to(title, path)
      end
    end

    def dropdown_item(title, path="#", options={})
      content_tag(:li) do
        link_to(title, path,options)
      end
    end

    def drop_down(title, path='#', options={}, &block)
      content_tag :li, :class => "dropdown #{is_active?(path,options)}" do
        drop_down_link(title,path) + drop_down_list(&block)
      end
    end

    def body_class
      return @cls if @cls
      @cls = []
      @cls << "#{params[:controller]}_controller"
      @cls << [params[:action],params[:controller]]*'_'
      @cls << I18n.locale.to_s
      @cls << Rails.env
      @cls << @body_class if @body_class
      @cls = @cls.map(&:parameterize)*' '
    end

    def controller_links
      links = ""
      Amalgam.admin_menus.each do |name,actions|
        unless actions.first.is_a? Hash
          links += drop_down name.classify.constantize.model_name.human,'#', :controller => "amalgam/admin/#{name}" do
            dropdown = ""
            actions.each do |action|
              dropdown += dropdown_item(I18n.t("amalgam.admin.actions.#{action}"), amalgam.send("admin_#{name}_path")) if action == 'index' || action == :index
              dropdown += dropdown_item(I18n.t('amalgam.admin.actions.new'), amalgam.send("new_admin_#{name.singularize}_path")) if action == 'new' || action == :new
              dropdown += dropdown_item(I18n.t("amalgam.admin.actions.#{action}"), amalgam.send("#{action}_admin_#{name}_path")) if action != 'index' && action != :index && action != 'new' && action != :new
            end
            dropdown.html_safe
          end
        else
          links += menu_item I18n.t("amalgam.admin.menus.#{name}"), amalgam.send("admin_#{name}_path"), :controller => "amalgam/admin/#{actions.first[:controller]}"
        end
      end
      links.html_safe
    end


    private

    def is_active?(path,options)
       controllers = options[:controller].is_a?(Array) ? options[:controller] : [options[:controller]].compact
      "active" if current_page?(path) || controller && controllers.include?(params[:controller])
    end

    def title_and_caret(title)
        "#{title} #{content_tag(:b, :class => "caret"){}}".html_safe
    end

    def drop_down_link(title,path)
      link_to(title_and_caret(title), path , :class => "dropdown-toggle", "data-toggle" => "dropdown")
    end

    def drop_down_list(&block)
      content_tag :ul, :class => "dropdown-menu", &block
    end
	end
end