class Admin::GroupsController < Admin::ApplicationController

  def edit
    @edited_group = Group.new
    @filter = params[:group_filter]
    @groups = Group.fetch @filter
  end

  def update
    s = params[:select]
    if !params[:get].blank?
      if s.blank?
        @edited_group = Group.new
        flash.now[:alert] = 'New group ready to edit.'
      else
        @edited_group = Group.find(s[0].to_i)
        flash.now[:alert] = 'Selected group ready to edit.'
      end
    elsif !params[:update].blank?
      id = params[:group][:id]
      if id.blank?
        g = Group.create(params[:group])
        if g.valid?
          flash.now[:alert] = "New group '#{params[:group][:description]}' was created."
          @edited_group = Group.new
        else
          flash.now[:alert] = "New group could not be created."
          @edited_group = g
        end
      else
        @edited_group = Group.find(id.to_i)
        @edited_group.update_attributes(params[:group])
        flash.now[:alert] = "Group '#{params[:group][:description]}' was updated."
      end
    elsif !params[:delete].blank?
      if s.blank?
        flash.now[:alert] = 'No groups were selected for deletion.'
      else
        Group.delete(s)
        flash.now[:alert] = 'Selected groups were deleted.'
      end
      @edited_group = Group.new
    end
    @filter = params[:group_filter]
    @groups = Group.fetch @filter
    render :action => :edit
  end
end
