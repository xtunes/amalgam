module Amalgam
	module Editable

    def self.included(base)
      base.layout :layout_with_mercury
    end

    protected

    def content_layout
      nil
    end

    private

    def layout_with_mercury
      !params[:mercury_frame] ? 'amalgam/admin/editor' : content_layout
    end
	end
end