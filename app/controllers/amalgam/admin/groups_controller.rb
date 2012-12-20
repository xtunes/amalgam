module Amalgam
  class Admin::GroupsController < Admin::BaseController

    def index
      @groups = Amalgam::Models::Group.all
    end

    def edit
      @group = Amalgam::Models::Group.find(params[:id])
    end

    def show
      @group = Amalgam::Models::Group.find(params[:id])
    end

    def new
      @group = Amalgam::Models::Group.new
    end

    def update
      @group = Amalgam::Models::Group.find(params[:id])
      respond_to do |format|
        format.html do
          if @group.update_attributes(params[:group])
            redirect_to admin_groups_path
          else
            render 'edit'
          end
        end
      end
    end

    def create
      @group = Amalgam::Models::Group.new(params[:group])
      respond_to do |format|
        format.html do
          if @group.save
            redirect_to admin_groups_path
          else
            render 'new'
          end
        end
      end
    end

    def destroy
      @group = Amalgam::Models::Group.find(params[:id])
      @group.destroy
      respond_to do |format|
        format.html{ redirect_to admin_groups_path}
      end
    end

  end
end