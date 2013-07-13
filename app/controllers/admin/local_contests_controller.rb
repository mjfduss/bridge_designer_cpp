class Admin::LocalContestsController < Admin::ApplicationController

  # TODO could paginate.

  def edit
    @edited_local_contest = LocalContest.new
    @local_contests = LocalContest.all
  end

  def update
    selected = params[:select]
    ids = params[:ids]
    ids = ids.split(',') if ids
    if params.nonblank? :get
      if selected.blank?
        @edited_local_contest = LocalContest.new
        flash.now[:alert] = 'New local contest ready to edit.'
      else
        @edited_local_contest = LocalContest.find(selected[0].to_i)
        flash.now[:alert] = 'Selected local contest ready to edit.'
      end
    elsif params.nonblank? :update
      id = params[:local_contest][:id]
      if id.blank?
        @edited_local_contest = LocalContest.create(params[:local_contest])
        if @edited_local_contest.valid?
          ids << @edited_local_contest.id if ids
          flash.now[:alert] = "New local contest '#{@edited_local_contest.code}' was created."
        else
          flash.now[:alert] = 'New local contest could not be created.'
        end
      else
        @edited_local_contest = LocalContest.find(id.to_i)
        if @edited_local_contest && @edited_local_contest.update_attributes(params[:local_contest])
          flash.now[:alert] = "Local contest '#{@edited_local_contest.code}' was updated."
        else
          flash.now[:alert] = 'Could not update local contest.'
        end
      end
    elsif params.nonblank? :delete
      if selected.blank?
        flash.now[:alert] = 'No local contests were selected for deletion.'
      else
        LocalContest.destroy(selected)
        flash.now[:alert] = 'Selected local contests were deleted.'
      end
      restore_edited
    elsif params.nonblank? :query
      @local_contests = LocalContest.qbe(params[:local_contest])
      @edited_local_contest = LocalContest.new(params[:local_contest])
      flash.now[:alert] = 'Query results are shown below.'
    end
    @local_contests ||= ids ? LocalContest.where(:id => ids) : LocalContest.all
    render :action => :edit
  end

  private

  def restore_edited
    id = params[:local_contest][:id]
    @edited_local_contest = id.blank? ? LocalContest.new : (LocalContest.find(id.to_i) || LocalContest.new)
  end

end
