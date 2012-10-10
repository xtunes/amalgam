module Amalgam
  class Admin::PagesController < Admin::BaseController
    def index
      @pages = Page.all

      respond_to do |format|
        format.html
        format.json { render :json => @pages }
      end
    end

    # GET /pages/1
    # GET /pages/1.json
    def show
      @page = Page.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @page }
      end
    end

    # GET /pages/new
    # GET /pages/new.json
    def new
      @parent = Page.find(params[:parent_id]) if params[:parent_id].present?
      @page = @parent? @parent.children.new : Page.new

      respond_to do |format|
        format.html # new.html.erb
        format.js {render :partial => 'inline_form'}
      end
    end

    def edit
      @page = Page.find(params[:id])
    end

    def create
      @page = Page.new(params[:page])
      respond_to do |format|
        if @page.save
          format.html { redirect_to admin_pages_path(:anchor => "node-#{@page.id}"), :notice => 'Page was successfully created.' }
        else
          format.html { render :action => "new" }
        end
        format.js
      end
    end

    def update
      @page = Page.find(params[:id])
      respond_to do |format|
        if @page.update_attributes(params[:page])
          format.html { redirect_to :back, :notice => 'Page was successfully updated.' }
        else
          format.html { render :action=> "edit" }
        end
        format.js
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.destroy

      respond_to do |format|
        format.html { redirect_to admin_pages_url }
        format.js
      end
    end
  end
end
