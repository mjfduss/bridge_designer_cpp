class Admin::GroupsController < Admin::ApplicationController

  def edit
    @edited_group = Group.new
    @groups = Group.all
  end

  def update
    selected = params[:select]
    ids = params[:ids]
    ids = ids.split(',') if ids

    if params.nonblank? :get
      if selected.blank?
        @edited_group = Group.new
        flash.now[:alert] = 'New group ready to edit.'
      else
        @edited_group = Group.find(selected[0].to_i)
        flash.now[:alert] = 'Selected group ready to edit.'
      end
    elsif params.nonblank? :update
      id = params[:group][:id]
      if id.blank?
        @edited_group = Group.create(params[:group])
        if @edited_group.valid?
          ids << @edited_group.id if ids
          flash.now[:alert] = "New group '#{params[:group][:description]}' was created."
        else
          flash.now[:alert] = "New group could not be created."
        end
      else
        @edited_group = Group.find(id.to_i)
        @edited_group.update_attributes(params[:group])
        flash.now[:alert] = "Group '#{params[:group][:description]}' was updated."
      end
    elsif params.nonblank? :delete
      if selected.blank?
        flash.now[:alert] = 'No groups were selected for deletion.'
      else
        Group.destroy(selected) # Destroy sets foreign keys in teams to null
        flash.now[:alert] = 'Selected groups were deleted.'
      end
      @edited_group = Group.new
    elsif params.nonblank? :query
      @groups = Group.qbe(params[:group])
      @edited_group = Group.new(params[:group])
      flash.now[:alert] = 'Query results are shown below.'
    end
    @groups ||= ids ? Group.where(:id => ids) : Group.all
    render :action => :edit
  end
end
