module Amalgam
  module Controller
    module Page
      extend ActiveSupport::Concern

      included do
        include Amalgam::TemplateFinder
        before_filter :load_page_model, :only => :show

        protected

        def load_page_model
          model_class = controller_name.classify.safe_constantize
          @page = model_class.where(:slug => params[:id]).first
          raise ActiveRecord::RecordNotFound , "Couldn't find page with slug=#{params[:id]}" if @page.blank?
          if @page.redirect.present?
            if @page.redirect.match(/^(http)|^(\/)/)
              redirect_to @page.redirect
            else
              redirect_to page_url(@page.redirect)
            end
          end
        end
      end
    end
  end
end